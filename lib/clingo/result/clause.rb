module Clingo
  module Result
    class Clause
      def initialize(clause, tree = nil)
        @clause = clause
        @tree = tree
      end

      def self.from_tree(tree)
        new(nil, tree)
      end

      def function
        return nil if structure == ""

        if structure.has_key?(:ident)
          return structure.fetch(:ident).str
        end

        if structure.has_key?(:func)
          return structure.dig(:func, :name).str
        end
      end

      def arguments
        return [] if structure == "" || structure.has_key?(:ident)

        structure.dig(:func, :args).map do |arg|
          case arg.keys.first
          when :ident
            arg.fetch(:ident).str.to_sym
          when :string
            arg.fetch(:string).str.gsub(/\A\"|\"\Z/, "")
          when :int
            arg.fetch(:int).str.to_i
          when :func
            Clause.from_tree(arg)
          else
            nil
          end
        end
      end

      private

      attr_reader :clause, :tree

      def structure
        @_structure ||= (@tree || parse(clause))
      end

      def parse(str)
        ClauseParser.new.parse(str)
      end
    end
  end
end
