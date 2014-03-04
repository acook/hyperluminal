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

require 'stringio'

module DebugInfo
  def debug *args
    default_options = {width: 20}
    options = args.last.is_a?(Hash) ? default_options.merge(args.pop) : default_options
    name, object = args

    if name.nil? && options[:newline] then
      multiple = options[:newline].is_a?(Numeric) ? options[:newline] : 1
      output.puts *(["\n"] * multiple)
    else

      if options[:header] then
        output.puts "\n"
        output.puts "### #{options[:header]} ###"
      end

      key  = object.to_s.slice 0, (options[:width] - 1)
      data = object

      output.puts "#{name.to_s.ljust(options[:width])} : #{data}"

      output.puts "\n" if options[:header] || options[:newline]
    end

    object
    output.string
  end

  def object_info object
    if object.is_a?(Class) then
      "class `#{object.name} < #{object.superclass}'"
    else
      "instance of `#{object.class} < #{object.class.superclass}'"
    end
  end

  def output
    @output ||= StringIO.new
  end
end

class FTLNode < Treetop::Runtime::SyntaxNode

  def explain
    if elements.none?{|e| e.is_a? FTLNode} then
      "<#{self.class} #{value}>"
    else
      result = StringIO.new
      result << "<#{self.class} "

      elements.each do |node|
        if node.respond_to? :explain then
          result << node.explain
        end
        result
      end

      result << '>'
      result.string
    end
  end

  def value
    text_value
  end

  def eval
    text_value
  end

end

class ParseError
  include DebugInfo

  def initialize parser, result, input
    @parser, @result, @input = parser, result, input
  end
  attr_reader :parser, :result, :input

  def explain
    norm  = "\e[0m"
    red   = "\e[31m"
    green = "\e[32m"

    if result.nil? || parser.index != input.length then

      debug 'failed to parse input',
        input.inspect, header: "#{red}PARSE ERROR#{norm}"

      debug 'error location', input.inspect[1..-2]
      debug '', "#{' ' * parser.index.to_i}#{red}^#{norm}"
      debug '', "#{' ' * parser.failure_index.to_i}#{red}^#{norm}"

      debug 'input length', input.length
      debug 'last index', parser.index, newline: 1

      debug 'terminal failures', parser.terminal_failures.inspect
      debug 'failure reason', parser.failure_reason.inspect
      debug 'failure line', parser.failure_line
      debug 'failure column', parser.failure_column
      debug 'failure index', parser.failure_index

      debug newline: 1

      debug "#{red}OUTPUT#{norm}", result.inspect, newline: 1

    else

      debug "#{green}OUTPUT#{norm}",
        "\n\n#{result.inspect}", header: "#{green}SUCCESSFUL PARSE#{norm}"

    end
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
  def explain
    rexplain self
  end

  def rexplain ast
    if ast.elements && !ast.elements.empty? then
      ast.elements.map do |node|
        if node.is_a? UnboundLiteral then
          rexplain node
        elsif node.is_a? FTLNode then
          node.explain
        else
          rexplain node
        end
      end.join
    else
      ''
    end
  end
end

class UnboundSequence < UnboundLiteral
end

class UnboundSequence0 < UnboundSequence
end

class DictionaryLiteral < FTLNode
end

class UnboundDictionary < UnboundLiteral
end

class PairLiteral < FTLNode
end

class BlockLiteral < FTLNode
end
