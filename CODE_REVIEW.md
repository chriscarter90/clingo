# Code Review: `clingo` gem

**Reviewed:** all source files (`lib/`, `spec/`)
**Scope:** correctness, security, API design, test coverage

---

## Summary

The gem wraps the Clingo ASP solver binary and parses its JSON output into Ruby objects. The core parsing pipeline (`ClauseParser` → `Clause` → `AnswerSet` → `Response`) is well-structured. However, there are four confirmed bugs that affect production correctness, one confirmed security vulnerability, and several coverage gaps where real failure paths have no tests.

---

## Critical

### 1. Shell injection via file paths — `runner.rb:12`

```ruby
%x[clingo --outf=2 -n #{num_solutions} #{dir_glob.join(" ")}]
```

File paths are interpolated directly into a shell string without quoting or escaping. A path containing `;`, `$(...)`, backticks, or spaces will be interpreted by the shell as command separators or substitutions.

**Verified:** passing `["valid.lp; echo INJECTED"]` as `dir_glob` executes `echo INJECTED` as a second shell command.

`dir_glob` originates from caller-supplied paths (via `Clingo.solve`) with no sanitisation at any layer. Any caller who accepts user-influenced file paths is vulnerable.

**Fix:** replace `%x[]` with `Open3.capture2e` and pass arguments as an array — no shell is invoked, each element is a literal argument:

```ruby
require "open3"

def run
  out, status = Open3.capture2e("clingo", "--outf=2", "-n", num_solutions.to_s, *dir_glob)
  raise "clingo failed: #{out}" unless status.success?
  JSON.parse(out)
end
```

---

### 2. `num_solutions` is unreachable from the public API — `client.rb:3`

`Client#initialize` accepts only one argument:

```ruby
def initialize(files)   # no num_solutions parameter
  @files = files
end

def solve
  runner = Runner.new(files)   # num_solutions never passed
  ...
end
```

`Clingo.solve` uses `*args` and splats them into `Client.new`, so calling `Clingo.solve(files, 5)` raises `ArgumentError: wrong number of arguments (given 2, expected 1)`. Even if that were fixed, `Client#solve` constructs `Runner.new(files)` with no second argument, permanently defaulting to `num_solutions = 0`.

`Runner` and its spec both support `num_solutions` correctly; the plumbing between the public API and the runner is simply missing.

**Verified:** `Clingo.solve(['puzzle.lp'], 5)` raises `ArgumentError`.

**Fix:** thread the parameter through `Client`:

```ruby
def initialize(files, num_solutions = 0)
  @files = files
  @num_solutions = num_solutions
end

def solve
  runner = Runner.new(files, num_solutions)
  ...
end
```

---

### 3. `answer_sets` raises `KeyError` on `UNKNOWN` and `INTERRUPTED` results — `result.rb:21`

```ruby
def answer_sets
  return [] if unsatisfiable?                                 # only guards "UNSATISFIABLE"

  answer_sets = response.fetch("Call").first.fetch("Witnesses")  # crashes here
  ...
end
```

Clingo emits `"Result": "UNKNOWN"` when solving is cut short by `--time-limit`, and `"INTERRUPTED"` on SIGINT. For both states `unsatisfiable?` returns false, so the guard is skipped. The `"Call"` entry for these states contains no `"Witnesses"` key, so `fetch("Witnesses")` raises `KeyError`.

**Verified:** constructing `Response.new({"Result" => "UNKNOWN", "Call" => [{}]})` and calling `answer_sets` raises `KeyError: key not found: "Witnesses"`.

**Fix:** guard on `satisfiable?` instead, and handle the missing-Witnesses case:

```ruby
def answer_sets
  return [] unless satisfiable?

  witnesses = response.fetch("Call").first&.fetch("Witnesses", []) || []
  witnesses.map { |s| Result::AnswerSet.new(s) }
end
```

---

### 4. Negative integers crash clause parsing — `clause_parser.rb:9`

```ruby
rule(:num) { match"[0-9]" }
rule(:int) { num.repeat(1) >> space? }
```

The `int` rule only matches `[0-9]+`. There is no provision for a leading minus sign. Negative integers are common in ASP programs (arithmetic, domain constants like `edge(-1, 2)`).

**Verified:**
- `Clause.new("edge(1,2)").arguments` → `[1, 2]` ✓
- `Clause.new("edge(-1,2)").arguments` → `Parslet::ParseFailed: Expected one of [SPACE?, func:FUNC, ident:IDENT] at line 1 char 1` ✗

Because `Clause#parse` does not rescue this exception, it propagates through `AnswerSet#clauses`'s `map` and crashes the entire answer set traversal for any program that uses negative values.

**Fix:** extend the `int` rule and the `arg` production:

```ruby
rule(:minus)  { str("-") }
rule(:int)    { minus.maybe >> num.repeat(1) >> space? }
```

---

## High

### 5. No exit-status check on clingo subprocess — `runner.rb:11`

`%x[]` captures only stdout; stderr is discarded. When clingo is absent from `PATH` or exits non-zero (syntax error in `.lp` file, out of memory, etc.), the method returns an empty string or a non-JSON error message, and `JSON.parse` raises `JSON::ParserError: unexpected token at ''`.

The caller has no way to distinguish a gem bug from a clingo failure. The fix (switching to `Open3.capture2e` per finding 1) also resolves this: capture stderr, check `status.success?`, and raise a descriptive error.

---

### 6. `Parslet::ParseFailed` escapes the library boundary — `clause.rb:52`

```ruby
def parse(str)
  ClauseParser.new.parse(str)   # no rescue
end
```

Any clause string that the grammar does not handle raises a parslet-internal exception that propagates through `AnswerSet#clauses`'s `map` to the gem consumer. Callers cannot distinguish a library bug from a known grammar limitation and cannot handle specific failure cases gracefully.

**Fix:** rescue and re-raise as a library-defined error:

```ruby
def parse(str)
  ClauseParser.new.parse(str)
rescue Parslet::ParseFailed => e
  raise Clingo::ParseError, "could not parse clause #{str.inspect}: #{e.message}"
end
```

---

### 7. `answer_sets` crashes on empty `Call` array — `result.rb:21`

`response.fetch("Call").first` returns `nil` if the `"Call"` array is present but empty. The subsequent `.fetch("Witnesses")` raises `NoMethodError: undefined method 'fetch' for nil`.

Clingo can produce this shape for an aborted run that writes partial JSON. The safe-navigation operator (`&.`) suggested in finding 3's fix addresses this.

---

## Medium

### 8. String rule rejects valid clingo string content — `clause_parser.rb:21`

```ruby
rule(:string) { dbl_qt >> (space | wordchar).repeat >> dbl_qt }
```

Only `[a-zA-Z0-9_]` and space are permitted inside double quotes. A quoted string argument containing hyphens, dots, slashes, or any other punctuation (e.g. `label("hello-world")`, `path("/tmp/foo")`) will raise `Parslet::ParseFailed`.

Clingo itself allows arbitrary characters in quoted string constants, so this grammar is narrower than what the solver can emit.

**Fix:** allow any non-quote, non-newline character inside a string:

```ruby
rule(:string) { dbl_qt >> (str('"').absent? >> any).repeat >> dbl_qt }
```

---

### 9. Multi-call/incremental solving silently drops results — `result.rb:21`

```ruby
answer_sets = response.fetch("Call").first.fetch("Witnesses")
```

`.first` hard-codes the first `"Call"` entry. Clingo's incremental solving mode (`#program step`, `--imin`/`--imax`) emits one entry per solving step, each with its own `"Witnesses"`. All steps beyond index 0 are silently discarded — no error, no warning, an incomplete result set.

---

## Low / Cleanup

### 10. `ANSWER_SET_REGEX` is dead code — `result.rb:4`

```ruby
ANSWER_SET_REGEX = /Answer: \d+\n(^.*$)\n/
```

**Verified with grep:** this constant has zero callers anywhere in the codebase. `Response` parses clingo's `--outf=2` JSON output via hash access; this regex was presumably left over from a text-format parsing approach. It should be deleted.

---

### 11. `attr_reader :_clauses` exposes the memoisation ivar — `answer_set.rb:16`

```ruby
private

attr_reader :solution, :_clauses
```

`@_clauses` is set and read by the `||=` assignment in `#clauses`; the generated `_clauses` reader is never called. Listing it in `attr_reader` generates an accessible (albeit private) method that returns `nil` before `clauses` is first called, which can confuse tests or subclasses that inspect it directly. Remove `:_clauses` from the `attr_reader` line.

---

## Test Coverage Gaps

| Gap | Risk |
|-----|------|
| `Clingo.solve` is never tested end-to-end | The broken `num_solutions` threading (finding 2) went undetected because only `Runner` is tested in isolation |
| `UNKNOWN` / `INTERRUPTED` result states have no test | Finding 3 (KeyError) is completely uncovered |
| Negative integers have no test | Finding 4 (ParseFailed) went undetected |
| `spec/clingo/result_spec.rb` only asserts `not_to be_nil` | This tautological test gives false confidence; any regression in `Result` passes it |
| Parser failure (malformed/unsupported clause) has no test | Finding 6 (unrescued ParseFailed) went undetected |
| Multi-call clingo output has no fixture | Finding 9 (silent data loss) is uncovered |

---

## Findings Summary

| # | File | Severity | Status |
|---|------|----------|--------|
| 1 | `runner.rb:12` | Critical — security | Confirmed |
| 2 | `client.rb:3` | Critical — API broken | Confirmed |
| 3 | `result.rb:21` | Critical — crash | Confirmed |
| 4 | `clause_parser.rb:9` | Critical — crash | Confirmed |
| 5 | `runner.rb:11` | High — error handling | Plausible |
| 6 | `clause.rb:52` | High — error handling | Plausible |
| 7 | `result.rb:21` | High — crash | Plausible |
| 8 | `clause_parser.rb:21` | Medium — data correctness | Plausible |
| 9 | `result.rb:21` | Medium — data correctness | Plausible |
| 10 | `result.rb:4` | Low — cleanup | Confirmed |
| 11 | `answer_set.rb:16` | Low — cleanup | Confirmed |
