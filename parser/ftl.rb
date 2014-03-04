require_relative 'explainers'
require_relative 'grammar'

class FTL
  extend BasicExplainer

  class << self
    def explain text
      basic_explain parse text
    end

    def parse text
      Grammar.parse text
    end
  end
end

