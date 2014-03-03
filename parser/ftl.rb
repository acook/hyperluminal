require_relative 'grammar'

class FTL
  class << self
    def explain text
      parse(text).explain
    end

    def parse text
      Grammar.parse text
    end
  end
end

