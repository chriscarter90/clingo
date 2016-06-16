$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "clingo"

ROOT = Pathname(File.expand_path(File.join(File.dirname(__FILE__), '..')))

Dir[File.join(ROOT, 'spec', 'support', '**', '*.rb')].each{|f| require f }

RSpec.configure do |config|
  config.include Fixtures
end
