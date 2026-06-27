require "spec_helper"

RSpec.describe Clingo::Runner do
  let(:file) { "spec/support/fixtures/inputs/test.lp" }
  let(:success) { instance_double(Process::Status, success?: true) }
  let(:failure) { instance_double(Process::Status, success?: false) }

  describe "#run" do
    it "returns a JSON parsed output from Clingo" do
      runner = Clingo::Runner.new([file])

      allow(Open3).to receive(:capture3)
        .with("clingo", "--outf=2", "-n", "0", file)
        .and_return(['{"some":"json"}', "", success])

      expect(runner.run).to eq({ "some" => "json" })
    end

    it "only gets the number of models specified" do
      runner = Clingo::Runner.new([file], 5)

      expect(Open3).to receive(:capture3)
        .with("clingo", "--outf=2", "-n", "5", file)
        .and_return(["{}", "", success])

      runner.run
    end

    it "raises a descriptive error when clingo fails" do
      runner = Clingo::Runner.new([file])

      allow(Open3).to receive(:capture3)
        .and_return(["", "clingo: command not found", failure])

      expect { runner.run }.to raise_error(RuntimeError, /clingo failed: clingo: command not found/)
    end

    describe "shell injection prevention" do
      # These specs assert that paths containing shell metacharacters are passed
      # as discrete verbatim arguments to Open3.capture3 — not joined into a
      # shell string where the metacharacters would be interpreted.

      it "passes a path containing a semicolon as a single literal argument" do
        path = "valid.lp; echo INJECTED"
        runner = Clingo::Runner.new([path])

        expect(Open3).to receive(:capture3)
          .with("clingo", "--outf=2", "-n", "0", path)
          .and_return(["{}", "", success])

        runner.run
      end

      it "passes a path containing command substitution syntax as a single literal argument" do
        path = "$(whoami).lp"
        runner = Clingo::Runner.new([path])

        expect(Open3).to receive(:capture3)
          .with("clingo", "--outf=2", "-n", "0", path)
          .and_return(["{}", "", success])

        runner.run
      end

      it "passes a path containing spaces as a single argument without word-splitting" do
        path = "my rules/program.lp"
        runner = Clingo::Runner.new([path])

        expect(Open3).to receive(:capture3)
          .with("clingo", "--outf=2", "-n", "0", path)
          .and_return(["{}", "", success])

        runner.run
      end
    end
  end
end
