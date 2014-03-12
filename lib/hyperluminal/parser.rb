class Parser
  def initialize file
    @file   = Pathname.new file
    @offset = 0
    @buffer = String.new
    @tokens = Array.new

    raise "File Not Found: #{file.inspect}" unless @file.exist?
  end
  attr_reader :file
  attr_accessor :buffer, :offset, :tokens
  attr_accessor :current_char, :current_token, :current_rule

  def explain
    parse
  end

  def parse
    debug_rule

    until eof?
      next_char and debug_char

      self.current_token ||= String.new

      transition = current_rule.transitions.find{|char, _| char === current_char }

      if transition then
        self.current_rule = transition.last
        debug_rule
      elsif current_rule.delimiters.include? current_char then
        unless current_token.empty? then
          debug_token
          tokens << current_token
          self.current_token = String.new
        end
      elsif current_char
        current_token << current_char
      end
    end

    tokens.inspect
  end

  def debug_char
    @nl = true # display a newline once after outputting a character
    printable = (/[[:graph:]]+/ === current_char) ? current_char : current_char.inspect[1..-2]
    print color(:green, printable) if current_char
  end

  def debug_rule
    puts "#{nl}RULE: #{current_rule}"
  end

  def debug_token
    puts "#{nl}TOKEN: #{current_token.gsub /[^[:graph:]]/, ?␣}"
  end

  def color name, text
    colors = {norm: "\e[0m", red: "\e[31m", green: "\e[32m"}
    "#{colors[name]}#{text}#{colors[:norm]}"
  end

  private

  def nl # whether to display a newline or not
    @nl ? (@nl = false; ?\n) : ''
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

  def current_rule
    @current_rule ||= Rules.root
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

  module Rules
    extend self

    def root
      rule :root
    end

    def rule name
      name  = name.is_a?(Rule) ? name.identifier : name
      const = rules.find{|r| name.to_s.downcase === r.to_s.downcase }

      if const.nil? then
        raise "ERROR RULE NOT FOUND: #{name.inspect}"
      else
        const_get const
      end
    end

    def rules
      constants.reject{|c| c == :Rule }
    end

    module Rule
      def identifier
        name.split('::').last
      end

      def transitions
        raise NotImplementedError
      end

      def patterns
        [anything]
      end

      def delimiters
        []
      end

      def special
        []
      end

      private

      def anything
        /.*/
      end

      def single_quote
        ?'
      end

      def space
        ' '
      end

      def newline
        ?\n
      end

      def backslash
        ?\\
      end
    end

    module Root
      extend Rule
      extend self

      def transitions
        {
          single_quote => SingleQuotedText
        }
      end

      def delimiters
        [space, newline]
      end
    end

    module SingleQuotedText
      extend Rule
      extend self

      def transitions
        {
          single_quote => Root
        }
      end

      def special
        [backslash]
      end
    end
  end
end
