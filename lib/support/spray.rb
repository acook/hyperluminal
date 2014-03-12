class Spray
  COLORS = {norm: "\e[0m", red: "\e[31m", green: "\e[32m"}

  def c name, text
    "#{COLORS[name]}#{text}#{COLORS[:norm]}"
  end

  def p text
    if text then
      @nl = true # display a newline once after outputting a character
      print c(:green, escape_text(text))
    end
  end

  def pnl text
    puts "#{nl}#{text}"
  end

  def escape_text text
    (/^[[:graph:]]+$/ === text) ? text : text.inspect[1..-2]
  end

  def make_printable text
    text.gsub /[^[:graph:]]/, ?␣
  end

  private

  def nl # whether to display a newline or not
    @nl ? (@nl = false; ?\n) : ''
  end

end
