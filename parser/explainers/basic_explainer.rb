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
