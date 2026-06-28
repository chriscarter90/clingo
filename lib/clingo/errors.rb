module Clingo
  class Error < StandardError; end
  class UnknownResultError < Error; end
  class InterruptedError < Error; end
end
