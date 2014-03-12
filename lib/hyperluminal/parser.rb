class Parser
  def initialize file
    @file   = Pathname.new file
    @offset = 0
    @buffer = String.new
    @tokens = Array.new

    raise "File Not Found: #{file.inspect}" unless @file.exist?
  end
  attr_reader :file
  attr_accessor :buffer, :current_char, :current_token, :offset, :tokens, :grammar

  def explain
    parse
  end

  def parse
    until eof?
      next_char and debug_char
      next_gram

      current_token ||= String.new

      if grammar.transitions.include? current_char then
        self.context = grammar.transitions.find{|char, _| char === current_char }.last
        puts "#{nl}CONTEXT: #{context}"
      elsif grammar.delimiters.include? current_char then
        unless current_token.empty? then
          puts "#{nl}TOKEN: #{current_token}"
          tokens << current_token
          current_token = String.new
        end
      elsif current_char
        current_token << current_char
      end
    end

    tokens.inspect
  end

  def debug_char
    next_nl
    printable = (/[[:graph:]]+/ === current_char) ? current_char : current_char.inspect[1..-2]
    print color(:green, printable) if current_char
  end

  def color name, text
    colors = {norm: "\e[0m", red: "\e[31m", green: "\e[32m"}
    "#{colors[name]}#{text}#{colors[:norm]}"
  end

  private

  def nl
    @nl ? (@nl = false; ?\n) : ''
  end

  def next_nl
    @nl = true
  end

  def next_char
    begin
      self.current_char = source.readchar
    rescue EOFError
      self.current_char = nil
      eof!
      source.close
    end

    if current_char then
      self.buffer << current_char
      self.offset += 1

      current_char
    end
  end

  def next_gram
    @grammar = Grammar.for context
  end

  def context
    @context ||= :root
  end

  def context= new_context
    @context = new_context
  end

  def source
    @source ||= file.open
  end

  def eof?
    @eof
  end

  def eof!
    @eof = true
  end

  class Grammar
    def self.for context
      new context
    end

    def initialize context = :root
      @context = context
    end
    attr_accessor :context

    def allowed
      case context
      when :root
        [/.*/]
      end
    end

    def transitions
      case context
      when :root
        {"'" => :single_quote}
      else
        {"'" => :root}
      end
    end

    def delimiters
      case context
      when :root
        [' ', ?\n]
      when :single_quote
        ["'"]
      end
    end
  end
end
