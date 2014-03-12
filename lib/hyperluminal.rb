require 'hyperluminal/parser'

module FTL; class Hyperluminal

  def self.parse file
    new(file).tap{|ftl| ftl.parse }
  end

  def initialize file
    @file = file
  end
  attr_reader :file, :parser

  def parse
    @parser = Parser.new file
    self
  end

  def explain
    puts parser.explain
  end

end; end
