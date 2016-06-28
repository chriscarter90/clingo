require "spec_helper"

RSpec.describe Clingo::Result::AnswerSet do
  describe "#clauses" do
    it "returns an array of clauses objects, given a solution from Clingo" do
      solution = {
        "Value" => [
          "clause(x,y)", "example(a,b)"
        ]
      }

      answer_set = Clingo::Result::AnswerSet.new(solution)

      expect(answer_set.clauses).to all(be_a(Clingo::Result::Clause))

      expect(answer_set.clauses.map(&:function)).to eq %w{clause example}
    end

    it "returns an array even if there is only one clause" do
      solution = {
        "Value" => [
          "yes"
        ]
      }

      answer_set = Clingo::Result::AnswerSet.new(solution)

      expect(answer_set.clauses).to all(be_a(Clingo::Result::Clause))

      expect(answer_set.clauses.map(&:function)).to eq %w{yes}
    end

    it "returns empty if there are no clauses" do
      solution = {
        "Value" => []
      }

      answer_set = Clingo::Result::AnswerSet.new(solution)

      expect(answer_set.clauses).to be_empty
    end
  end
end
