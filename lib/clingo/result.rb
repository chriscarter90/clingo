module Clingo
  module Result
    class Response
      ANSWER_SET_REGEX = /Answer: \d+\n(^.*$)\n/

      def initialize(response)
        @response = response
      end

      def satisfiable?
        result == "SATISFIABLE"
      end

      def unsatisfiable?
        result == "UNSATISFIABLE"
      end

      def unknown?
        result == "UNKNOWN"
      end

      def interrupted?
        result == "INTERRUPTED"
      end

      def answer_sets
        return [] if unsatisfiable?
        raise Clingo::UnknownResultError if unknown?
        raise Clingo::InterruptedError   if interrupted?

        witnesses = response.fetch("Call").first&.fetch("Witnesses", []) || []

        witnesses.map { |s| Result::AnswerSet.new(s) }
      end

      private

      attr_reader :response

      def result
        response.fetch("Result")
      end
    end
  end
end


require "clingo/result/clause"
require "clingo/result/clause_parser"
require "clingo/result/answer_set"
