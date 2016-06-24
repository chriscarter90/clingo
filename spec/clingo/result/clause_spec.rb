require "spec_helper"

RSpec.describe Clingo::Result::Clause do
  describe "#function" do
    it "returns the function of the clause" do
      clause = Clingo::Result::Clause.new("function(a1,a2)")

      expect(clause.function).to eq "function"
    end

    it "returns the function of the clause even if there are no arguments" do
      clause = Clingo::Result::Clause.new("function()")

      expect(clause.function).to eq "function"
    end

    it "returns the identifier of the clause if there is no function" do
      clause = Clingo::Result::Clause.new("atom")

      expect(clause.function).to eq "atom"
    end

    it "returns nil if provided with a blank string" do
      clause = Clingo::Result::Clause.new("")

      expect(clause.function).to be_nil
    end
  end

  describe "#arguments" do
    it "returns the arguments of the clause" do
      clause = Clingo::Result::Clause.new("function(a1,2)")

      expect(clause.arguments).to eq ["a1", 2]
    end

    it "returns functions as nested clauses" do
      clause = Clingo::Result::Clause.new("function(a1, nest(1,2))")

      expect(clause.arguments.length).to eq 2

      expect(clause.arguments.first).to eq "a1"

      expect(clause.arguments.last).to be_a Clingo::Result::Clause
      expect(clause.arguments.last.function).to eq "nest"
      expect(clause.arguments.last.arguments).to eq [1, 2]
    end

    it "returns an empty array if there are no arguments" do
      clause = Clingo::Result::Clause.new("atom")

      expect(clause.arguments).to be_empty
    end

    it "returns empty if provided with a blank string" do
      clause = Clingo::Result::Clause.new("")

      expect(clause.arguments).to be_empty
    end
  end
end
