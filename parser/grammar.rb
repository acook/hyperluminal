require 'rubygems'
require 'treetop'
require 'pry'

Dir[File.dirname(__FILE__) + '/nodes/*.rb'].each {|file| require file }

class Grammar
  def self.parse *args
    new.parse *args
  end

  def parse *args
    @last_input = args.first
    result = parser.parse *args

    @last_result = result || ParseError.new(parser, result, @last_input)
  end

  def last_result
    @last_result
  end

  def last_input
    @last_input
  end

  def parser
    @parser ||= instantiate_parser
  end

  def grammar
    @grammar ||= load_grammar
  end

  private

  def instantiate_parser
    grammar.new.tap{|g| g.consume_all_input = false }
  end

  def load_grammar
    Treetop.load Pathname.pwd.join('parser', 'grammar.treetop').to_s
  end
end
