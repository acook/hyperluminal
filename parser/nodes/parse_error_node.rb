module Hyperluminal
  class ParseError
    include DebugExplainer

    def initialize parser, result, input
      @parser, @result, @input = parser, result, input
    end
    attr_reader :parser, :result, :input

    def explain
      debug_explainer parser, result, input
    end
  end
end
