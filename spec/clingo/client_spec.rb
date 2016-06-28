require "spec_helper"

RSpec.describe Clingo::Client do
  describe "#solve" do
    it "returns the parsed result of the run" do
      client = Clingo::Client.new(
        Dir.glob("spec/support/fixtures/inputs/test.lp")
      )

      expect(client.solve).to be_a(Clingo::Result::Result)
    end
  end
end
