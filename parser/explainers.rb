module BasicExplainer
  def decide_explain ast
    ast.respond_to?(:explain) && ast.explain || basic_explain(ast)
  end

  def basic_explain ast
    if ast.elements.none?{|e| e.is_a? BasicExplainer} then
      value = ast.respond_to?(:value) ? ast.value : ast.text_value
      "<#{class_info ast} #{value}>"
    else
      result = StringIO.new
      result << "<#{class_info ast} " if ast.is_a? BasicExplainer

      ast.elements.each do |node|
        if node.respond_to? :explain then
          result << node.explain
        end
        result
      end

      result << '>' if ast.is_a? BasicExplainer
      result.string
    end
  end

  def class_info ast
    ast.class.to_s.gsub /(\w*::)*(\w*)/, '\2'
  end
end

module NestedExplainer
  include BasicExplainer

  def descend_explain ast
    "<#{class_info ast} #{nested_explain ast}>"
  end

  def nested_explain ast
    if ast.elements && !ast.elements.empty? then
      ast.elements.map do |node|
        if node.is_a? NestedExplainer then
          nested_explain node
        elsif node.is_a? BasicExplainer then
          node.explain
        else
          nested_explain node
        end
      end.join
    else
      ''
    end
  end
end

require_relative 'debug_info'
module DebugExplainer
  include DebugInfo
  def debug_explainer parser, result, input
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
