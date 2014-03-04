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

