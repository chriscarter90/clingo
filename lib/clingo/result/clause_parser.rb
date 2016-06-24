require "parslet"

module Clingo
  module Result
    class ClauseParser < Parslet::Parser
      rule(:lower)    { match("[a-z]") }
      rule(:upper)    { match("[A-Z]") }
      rule(:letter)   { lower | upper }
      rule(:num)      { match"[0-9]" }
      rule(:us)       { str("_") }
      rule(:comma)    { str(",") >> space? }
      rule(:wordchar) { letter | num | us }

      rule(:space)    { match("\s").repeat(1) }
      rule(:space?)   { space.maybe }

      rule(:lparen)   { str("(") >> space? }
      rule(:rparen)   { str(")") >> space? }
      rule(:ident)    { lower >> wordchar.repeat >> space? }
      rule(:int)      { num.repeat(1) >> space? }

      rule(:arg)      { func.as(:func) | ident.as(:ident) | int.as(:int) }
      rule(:args)     { arg >> (comma >> arg).repeat }
      rule(:func)     { ident.as(:name) >> lparen >> args.repeat(0,1).as(:args) >> rparen }

      rule(:clause)   { space? | func.as(:func) | ident.as(:ident) }

      root :clause
    end
  end
end
