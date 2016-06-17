module Clingo
  module Result
    class Clause
      CLAUSE_REGEX = /\b([\w]+)(\([\w,]*\))?/

      def initialize(clause)
        @clause = clause
      end

      def function
        return nil if clause == ""

        @_function ||= clause.scan(/\b([\w]+)(\([\w,]*\))?/).first.first
      end

      private

      attr_reader :clause, :_function
    end
  end
end
