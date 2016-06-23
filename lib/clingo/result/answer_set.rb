module Clingo
  module Result
    class AnswerSet
      def initialize(solution)
        @solution = solution
      end

      def clauses
        @_clauses ||= solution.split(" ").map do |c|
          Clause.new(c)
        end
      end

      private

      attr_reader :solution, :_clauses
    end
  end
end
