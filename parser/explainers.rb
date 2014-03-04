module BasicExplainer
  def basic_explain ast, root = false
    if ast.elements.none?{|e| e.is_a? FTLNode} then
      value = ast.respond_to?(:value) ? ast.value : ast.text_value
      "<#{ast.class} #{value}>"
    else
      result = StringIO.new
      result << "<#{ast.class} " if !root and ast.is_a? FTLNode

      ast.elements.each do |node|
        if node.respond_to? :explain then
          result << node.explain
        end
        result
      end

      result << '>' if !root and ast.is_a? FTLNode
      result.string
    end
  end
end
