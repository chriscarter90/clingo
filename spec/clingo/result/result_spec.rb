require "spec_helper"

RSpec.describe Clingo::Result::Result do
  describe "#satisfiable?" do
    it "returns true if the provided result is satisfiable" do
      result = Clingo::Result::Result.new(
        fixture_file("satisfiable.txt")
      )

      expect(result).to be_satisfiable
    end

    it "returns false if the provided result is not satisfiable" do
      result = Clingo::Result::Result.new(
        fixture_file("unsatisfiable.txt")
      )

      expect(result).not_to be_satisfiable
    end
  end

  describe "#unsatisfiable?" do
    it "returns true if the provided result is unsatisfiable" do
      result = Clingo::Result::Result.new(
        fixture_file("unsatisfiable.txt")
      )

      expect(result).to be_unsatisfiable
    end

    it "returns false if the provided result is not unsatisfiable" do
      result = Clingo::Result::Result.new(
        fixture_file("satisfiable.txt")
      )

      expect(result).not_to be_unsatisfiable
    end
  end
end
