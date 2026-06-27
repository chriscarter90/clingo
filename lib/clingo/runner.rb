require "json"
require "open3"

module Clingo
  class Runner
    def initialize(dir_glob, num_solutions = 0)
      @dir_glob = dir_glob
      @num_solutions = num_solutions
    end

    def run
      stdout, stderr, status = Open3.capture3(
        "clingo", "--outf=2", "-n", num_solutions.to_s, *dir_glob
      )

      raise "clingo failed: #{stderr.strip}" unless status.success?

      JSON.parse(stdout)
    end

    private

    attr_reader :dir_glob, :num_solutions
  end
end
