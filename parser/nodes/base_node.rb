module Hyperluminal
  class FTLNode < Treetop::Runtime::SyntaxNode
    include BasicExplainer

    def explain
      basic_explain self
    end

    def value
      text_value
    end
  end
end
