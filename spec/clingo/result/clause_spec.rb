require "spec_helper"

RSpec.describe Clingo::Result::Clause do
  describe "#function" do
    it "returns the function of the clause" do
      clause = Clingo::Result::Clause.new("function(a1,a2)")

      expect(clause.function).to eq "function"
    end

    it "returns the function of the clause even if there are no arguments" do
      clause = Clingo::Result::Clause.new("atom")

      expect(clause.function).to eq "atom"
    end

    it "returns nil if provided with a blank string" do
      clause = Clingo::Result::Clause.new("")

      expect(clause.function).to be_nil
    end
  end
end
