module Clingo
  class Client
    def initialize(files)
      @files = files
    end

    def solve
      runner = Runner.new(files)

      Result::Result.new(runner.run)
    end

    private

    attr_reader :files
  end
end
