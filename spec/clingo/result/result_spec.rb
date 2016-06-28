require "spec_helper"

RSpec.describe Clingo::Result::Result do
  describe "#satisfiable?" do
    it "returns true if the provided result is satisfiable" do
      result = Clingo::Result::Result.new(
        JSON.parse(fixture_file("results/satisfiable.json"))
      )

      expect(result).to be_satisfiable
    end

    it "returns false if the provided result is not satisfiable" do
      result = Clingo::Result::Result.new(
        JSON.parse(fixture_file("results/unsatisfiable.json"))
      )

      expect(result).not_to be_satisfiable
    end
  end

  describe "#unsatisfiable?" do
    it "returns true if the provided result is unsatisfiable" do
      result = Clingo::Result::Result.new(
        JSON.parse(fixture_file("results/unsatisfiable.json"))
      )

      expect(result).to be_unsatisfiable
    end

    it "returns false if the provided result is not unsatisfiable" do
      result = Clingo::Result::Result.new(
        JSON.parse(fixture_file("results/satisfiable.json"))
      )

      expect(result).not_to be_unsatisfiable
    end
  end

  describe "#answer_sets" do
    context "when unsatisfiable" do
      it "returns an empty array of answer sets" do
        result = Clingo::Result::Result.new(
          JSON.parse(fixture_file("results/unsatisfiable.json"))
        )

        expect(result.answer_sets).to be_empty
      end
    end

    context "when satisfiable" do
      context "with only one solution" do
        it "returns only one answer set" do
          result = Clingo::Result::Result.new(
            JSON.parse(fixture_file("results/satisfiable.json"))
          )

          expect(result.answer_sets.length).to eq 1

          answer_set = result.answer_sets.first

          expect(answer_set.clauses.length).to eq 1
          expect(answer_set.clauses.first.function).to eq "yes"
        end
      end

      context "with many solutions" do
        it "returns only one answer set" do
          result = Clingo::Result::Result.new(
            JSON.parse(fixture_file("results/multi_answer.json"))
          )

          expect(result.answer_sets.length).to eq 3

          expect(result.answer_sets.map { |s| s.clauses.length }).to all(eq 2)
          expect(result.answer_sets.map { |s| s.clauses.map(&:function) }).to all(eq ["picked", "picked"])
        end
      end
    end
  end
end
