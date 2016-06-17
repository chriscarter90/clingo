require "spec_helper"

RSpec.describe Clingo::Result::AnswerSet do
  describe "#clauses" do
    it "returns an array of clauses given a solution" do
      solution = "clause(x,y) example(a,b)"

      answer_set = Clingo::Result::AnswerSet.new(solution)

      expect(answer_set.clauses).to eq [
        "clause(x,y)",
        "example(a,b)"
      ]
    end

    it "returns an array even if there is only one clause" do
      solution = "yes"

      answer_set = Clingo::Result::AnswerSet.new(solution)

      expect(answer_set.clauses).to eq [
        "yes"
      ]
    end

    it "returns empty if there are no clauses" do
      solution = ""

      answer_set = Clingo::Result::AnswerSet.new(solution)

      expect(answer_set.clauses).to be_empty
    end
  end
end
