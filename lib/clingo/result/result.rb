module Clingo
  module Result
    class Result
      ANSWER_SET_REGEX = /Answer: \d+\n(^.*$)\n/

      def initialize(result)
        @result = result
      end

      def satisfiable?
        result.fetch("Result") == "SATISFIABLE"
      end

      def unsatisfiable?
        result.fetch("Result") == "UNSATISFIABLE"
      end

      def answer_sets
        return [] if unsatisfiable?

        answer_sets = result.fetch("Call").first.fetch("Witnesses")

        answer_sets.map { |s| AnswerSet.new(s) }
      end

      private

      attr_reader :result
    end
  end
end
