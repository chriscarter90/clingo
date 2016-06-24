require "spec_helper"

RSpec.describe Clingo::Result::ClauseParser do
  describe "#parse" do
    it "parses empty" do
      expect_to_parse(
        "",
        ""
      )
    end

    it "parses atoms" do
      expect_to_parse(
        "atom",
        {
          ident: Parslet::Slice.new(0, "atom")
        }
      )
    end

    it "parses functions with no arguments" do
      expect_to_parse(
        "function()",
        {
          func: {
            name: Parslet::Slice.new(0, "function"),
            args: []
          }
        }
      )
    end

    it "parses functions with some simple arguments" do
      expect_to_parse(
        "function(1, hello)",
        {
          func: {
            name: Parslet::Slice.new(0, "function"),
            args: [
              {
                int: Parslet::Slice.new(9, "1"),
              },
              {
                ident: Parslet::Slice.new(12, "hello")
              }
            ]
          }
        }
      )
    end

    it "parses functions with some nested functions as arguments" do
      expect_to_parse(
        "function(f1(1), f2(two))",
        {
          func: {
            name: Parslet::Slice.new(0, "function"),
            args: [
              {
                func: {
                  name: Parslet::Slice.new(9, "f1"),
                  args: [
                    {
                      int: Parslet::Slice.new(12, "1")
                    }
                  ]
                }
              }, {
                func:
                {
                  name: Parslet::Slice.new(16, "f2"),
                  args: [
                    ident: Parslet::Slice.new(19, "two")
                  ]
                }
              }
            ]
          }
        }
      )
    end

    def expect_to_parse(str, tree)
      expect(subject.parse(str)).to eq tree
    end
  end
end
