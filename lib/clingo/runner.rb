require "json"

module Clingo
  class Runner
    def initialize(dir_glob, num_solutions = 0)
      @dir_glob = dir_glob
      @num_solutions = num_solutions
    end

    def run
      JSON.parse(
        %x[bin/clingo --outf=2 -n #{num_solutions} #{dir_glob.join(" ")}]
      )
    end

    private

    attr_reader :dir_glob, :num_solutions
  end
end
