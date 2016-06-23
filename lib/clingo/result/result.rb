module Clingo
  module Result
    class Result
      ANSWER_SET_REGEX = /Answer: \d+\n(^.*$)\n/

      def initialize(result)
        @result = result
      end

      def satisfiable?
        !!(result =~ /^SATISFIABLE$/)
      end

      def unsatisfiable?
        !!(result =~ /^UNSATISFIABLE$/)
      end

      def answer_sets
        return [] if unsatisfiable?

        answer_strings = result.scan(ANSWER_SET_REGEX).map(&:first)

        answer_strings.map { |s| AnswerSet.new(s) }
      end

      private

      attr_reader :result
    end
  end
end
