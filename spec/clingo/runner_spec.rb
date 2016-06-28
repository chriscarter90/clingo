require "spec_helper"

RSpec.describe Clingo::Runner do
  describe "#run" do
    it "returns a JSON parsed output from Clingo" do
      runner = Clingo::Runner.new(
        Dir.glob("spec/support/fixtures/inputs/test.lp")
      )

      allow(runner).to receive(:`).with(
        "bin/clingo --outf=2 -n 0 spec/support/fixtures/inputs/test.lp"
      ).and_return('{"some":"json"}')

      expect(runner.run).to eq({ "some" => "json" })
    end

    it "only gets the number of models specified" do
      runner = Clingo::Runner.new(
        Dir.glob("spec/support/fixtures/inputs/test.lp"),
        5
      )

      expect(runner).to receive(:`).with(
        "bin/clingo --outf=2 -n 5 spec/support/fixtures/inputs/test.lp"
      ).and_return('{}')

      runner.run
    end
  end
end
