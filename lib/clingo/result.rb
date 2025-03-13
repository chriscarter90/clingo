module Clingo
  class Response
    ANSWER_SET_REGEX = /Answer: \d+\n(^.*$)\n/

    def initialize(response)
      @response = response
    end

    def satisfiable?
      response.fetch("Result") == "SATISFIABLE"
    end

    def unsatisfiable?
      response.fetch("Result") == "UNSATISFIABLE"
    end

    def answer_sets
      return [] if unsatisfiable?

      answer_sets = response.fetch("Call").first.fetch("Witnesses")

      answer_sets.map { |s| Result::AnswerSet.new(s) }
    end

    private

    attr_reader :response
  end
end


require "clingo/result/clause"
require "clingo/result/clause_parser"
require "clingo/result/answer_set"
