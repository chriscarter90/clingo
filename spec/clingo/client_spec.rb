require "spec_helper"

RSpec.describe Clingo::Client do
  let(:files) { Dir.glob("spec/support/fixtures/inputs/test.lp") }
  let(:runner) { instance_double(Clingo::Runner) }
  let(:satisfiable_result) { JSON.parse(fixture_file("results/satisfiable.json")) }

  before do
    allow(runner).to receive(:run).and_return(satisfiable_result)
  end

  describe "#solve" do
    it "returns the parsed result of the run" do
      allow(Clingo::Runner).to receive(:new).and_return(runner)

      expect(Clingo::Client.new(files).solve).to be_a(Clingo::Result::Response)
    end

    it "defaults to requesting all solutions" do
      expect(Clingo::Runner).to receive(:new).with(files, num_solutions: 0).and_return(runner)

      Clingo::Client.new(files).solve
    end

    it "threads num_solutions through to Runner" do
      expect(Clingo::Runner).to receive(:new).with(files, num_solutions: 5).and_return(runner)

      Clingo::Client.new(files, num_solutions: 5).solve
    end
  end
end
