module Hyperluminal
  class Setword < FTLNode
  end

  class Assignment < FTLNode
  end

  class Setword < FTLNode
    def value
      text_value.sub(':','').strip
    end
  end

  class SetwordLocal < Setword
  end

  class SetwordPathable < Setword
  end
end
