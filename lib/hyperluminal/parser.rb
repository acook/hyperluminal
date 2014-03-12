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
      puts "CHAR: #{next_char.inspect}"
      next_gram

      current_token ||= String.new
      if grammar.delimiters.include? current_char then
        unless current_token.empty? then
          tokens << current_token
          current_token = String.new
        end
      elsif current_char
        current_token << current_char
        puts "TOKEN: #{current_token}"
      end
    end

    tokens.inspect
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
