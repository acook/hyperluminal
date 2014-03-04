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
