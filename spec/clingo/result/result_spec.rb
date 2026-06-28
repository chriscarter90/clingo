require "spec_helper"

RSpec.describe Clingo::Result::Response do
  def result_for(result_string)
    Clingo::Result::Response.new({ "Result" => result_string })
  end

  describe "#satisfiable?" do
    it "returns true if the provided result is satisfiable" do
      expect(result_for("SATISFIABLE")).to be_satisfiable
    end

    it "returns false if the provided result is not satisfiable" do
      expect(result_for("UNSATISFIABLE")).not_to be_satisfiable
    end
  end

  describe "#unsatisfiable?" do
    it "returns true if the provided result is unsatisfiable" do
      expect(result_for("UNSATISFIABLE")).to be_unsatisfiable
    end

    it "returns false if the provided result is not unsatisfiable" do
      expect(result_for("SATISFIABLE")).not_to be_unsatisfiable
    end
  end

  describe "#unknown?" do
    it "returns true if the result is unknown" do
      expect(result_for("UNKNOWN")).to be_unknown
    end

    it "returns false if the result is not unknown" do
      expect(result_for("SATISFIABLE")).not_to be_unknown
    end
  end

  describe "#interrupted?" do
    it "returns true if the result is interrupted" do
      expect(result_for("INTERRUPTED")).to be_interrupted
    end

    it "returns false if the result is not interrupted" do
      expect(result_for("SATISFIABLE")).not_to be_interrupted
    end
  end

  describe "#answer_sets" do
    context "when unsatisfiable" do
      it "returns an empty array of answer sets" do
        expect(result_for("UNSATISFIABLE").answer_sets).to be_empty
      end
    end

    context "when unknown" do
      it "raises Clingo::UnknownResultError" do
        expect { result_for("UNKNOWN").answer_sets }.to raise_error(Clingo::UnknownResultError)
      end
    end

    context "when interrupted" do
      it "raises Clingo::InterruptedError" do
        expect { result_for("INTERRUPTED").answer_sets }.to raise_error(Clingo::InterruptedError)
      end
    end

    context "when satisfiable" do
      context "with only one solution" do
        it "returns only one answer set" do
          result = Clingo::Result::Response.new(
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
          result = Clingo::Result::Response.new(
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
