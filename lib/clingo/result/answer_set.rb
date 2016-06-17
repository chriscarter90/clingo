module Clingo
  module Result
    class AnswerSet
      def initialize(solution)
        @solution = solution
      end

      def clauses
        solution.split(" ")
      end

      private

      attr_reader :solution
    end
  end
end
