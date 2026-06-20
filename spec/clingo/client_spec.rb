require "spec_helper"

RSpec.describe Clingo::Client do
  describe "#solve" do
    it "returns the parsed result of the run" do
      client = Clingo::Client.new(
        Dir.glob("spec/support/fixtures/inputs/test.lp")
      )

      runner = instance_double(Clingo::Runner)
      allow(Clingo::Runner).to receive(:new).and_return(runner)
      allow(runner).to receive(:run).and_return(
        JSON.parse(fixture_file("results/satisfiable.json"))
      )

      expect(client.solve).to be_a(Clingo::Result::Response)
    end
  end
end
