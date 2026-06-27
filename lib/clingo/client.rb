module Clingo
  class Client
    def initialize(files, num_solutions: 0)
      @files = files
      @num_solutions = num_solutions
    end

    def solve
      runner = Runner.new(files, num_solutions: num_solutions)

      Result::Response.new(runner.run)
    end

    private

    attr_reader :files, :num_solutions
  end
end
