module Clingo
  module Result
    class Result
      def initialize(result)
        @result = result
      end

      def satisfiable?
        !!(result =~ /^SATISFIABLE$/)
      end

      def unsatisfiable?
        !!(result =~ /^UNSATISFIABLE$/)
      end

      private

      attr_reader :result
    end
  end
end
