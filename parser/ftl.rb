require 'rubygems'
require 'treetop'
require 'pry'

Dir[File.dirname(__FILE__) + '/explainers/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/nodes/*.rb'].each {|file| require file }

require_relative 'grammar'

class FTL
  extend BasicExplainer

  class << self
    def explain text
      decide_explain parse text
    end

    def parse text
      Grammar.parse text
    end
  end
end

