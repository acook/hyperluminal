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
        puts "\nSTATE: #{context}"
      elsif grammar.delimiters.include? current_char then
        unless current_token.empty? then
          puts "\nTOKEN: #{current_token}"
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
    printable = (/[[:print:]]*/ === current_char) ? current_char : current_char.inspect
    print printable if current_char
  end

  private

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
    def self.for state
      new state
    end

    def initialize state = :root
      @state = state
    end
    attr_accessor :state

    def allowed
      case state
      when :root
        [/.*/]
      end
    end

    def transitions
      case state
      when :root
        {"'" => :single_quote}
      else
        {"'" => :root}
      end
    end

    def delimiters
      case state
      when :root
        [' ', ?\n]
      when :single_quote
        ["'"]
      end
    end
  end
end
