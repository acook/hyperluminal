module BasicExplainer
  def decide_explain ast
    ast.respond_to?(:explain) && ast.explain || basic_explain(ast)
  end

  def basic_explain ast
    if ast.elements.none?{|e| e.is_a? FTLNode} then
      value = ast.respond_to?(:value) ? ast.value : ast.text_value
      "<#{ast.class} #{value}>"
    else
      result = StringIO.new
      result << "<#{ast.class} " if ast.is_a? FTLNode

      ast.elements.each do |node|
        if node.respond_to? :explain then
          result << node.explain
        end
        result
      end

      result << '>' if ast.is_a? FTLNode
      result.string
    end
  end
end

module NestedExplainer
  include BasicExplainer

  def descend_explain ast
    "<#{ast.class} #{nested_explain ast}>"
  end

  def nested_explain ast
    if ast.elements && !ast.elements.empty? then
      ast.elements.map do |node|
        if node.is_a? UnboundLiteral then
          nested_explain node
        elsif node.is_a? FTLNode then
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

