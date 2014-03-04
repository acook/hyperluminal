require 'rubygems'
require 'treetop'
require 'pry'

class Grammar
  def self.parse *args
    new.parse *args
  end

  def parse *args
    result = parser.parse *args
    input = args.first

    result || ParseError.new(parser, result, input)
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

module Hyperluminal
class FTLNode < Treetop::Runtime::SyntaxNode
  include BasicExplainer

  def explain
    basic_explain self
  end

  def value
    text_value
  end

  def eval
    text_value
  end

end

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

class NumberLiteral < FTLNode
end

class TextLiteral < FTLNode
end

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
