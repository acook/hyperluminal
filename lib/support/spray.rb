class Spray
  COLORS = {norm: "\e[0m", red: "\e[31m", green: "\e[32m"}

  def c name, text
    "#{COLORS[name]}#{text}#{COLORS[:norm]}"
  end

  def p text
    if text then
      @nl = true # display a newline once after outputting a character
      print c(pop_color, escape_text(text))
    end
  end

  def pnl text
    puts c(pop_color, "#{nl}#{make_printable text}")
  end

  def escape_text text
    (/^[[:graph:]]+$/ === text) ? text : text.inspect[1..-2]
  end

  def make_printable text
    text = text.dup
    text.gsub /[^ [:graph:]]/, ?␣
  end

  def method_missing name, *args, &block
    if COLORS.keys.include? name then
      text = args.first
      if text then
        c name, text
      else
        @next_color = name
        self
      end
    else
      super
    end
  end

  private

  def pop_color
    color = @next_color
    @next_color = nil
    color || :norm
  end

  def nl # whether to display a newline or not
    @nl ? (@nl = false; ?\n) : ''
  end

end
