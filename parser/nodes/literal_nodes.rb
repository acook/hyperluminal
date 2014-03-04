module Hyperluminal
  class NumberLiteral < FTLNode
  end

  class TextLiteral < FTLNode
  end

  class SequenceLiteral < FTLNode
  end

  class UnboundLiteral < FTLNode
    include NestedExplainer

    def explain
      nested_explain self
    end
  end

  class UnboundSequence < UnboundLiteral
  end

  class DictionaryLiteral < FTLNode
  end

  class UnboundDictionary < UnboundLiteral
  end

  class PairLiteral < FTLNode
  end

  class BlockLiteral < FTLNode
    include NestedExplainer

    def explain
      descend_explain self
    end
  end

  class BlockMultiLiteral < BlockLiteral
    include NestedExplainer

    def explain
      descend_explain self
    end
  end
end
