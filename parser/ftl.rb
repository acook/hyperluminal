require_relative 'grammar'

class FTL
  class << self
    def explain text
      result = parse(text)
      if result.respond_to? :explain then
        result.explain
      else
        binding.pry
        result.inspect
      end
    end

    def parse text
      Grammar.parse text
    end
  end
end

