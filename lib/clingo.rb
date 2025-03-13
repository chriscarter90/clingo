module Clingo
  def self.solve(*args)
    Client.new(*args).solve
  end
end

require "clingo/version"

require "clingo/runner"
require "clingo/result"
require "clingo/client"
