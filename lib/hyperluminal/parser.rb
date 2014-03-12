require 'support/spray'

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

      transition = current_rule.transition current_char

      if transition then
        self.current_rule = transition.last
        debug_rule
      elsif current_rule.delimit current_char then
        unless current_token.empty? then
          debug_token
          tokens << current_token
          self.current_token = String.new
        end
      elsif current_rule.matches current_char then
        current_token << current_char
      elsif !eof?
        raise 'FAILED TO PARSE'
      end
    end

    tokens.inspect
  end

  def debug_char
    spray.p current_char
  end

  def debug_rule
    spray.red.pnl "RULE: #{current_rule}"
  end

  def debug_token
    spray.green.pnl "TOKEN: #{current_token}"
  end

  private

  def spray
    @spray ||= Spray.new
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

      def transition token
        transitions.find{|match, _| match === token }
      end

      def patterns
        [anything]
      end

      def matches token
        return false if token.nil?
        patterns.select{|pattern| pattern === token }
      end

      def delimiters
        []
      end

      def delimit token
        delimiters.include? token
      end

      def remember
        []
      end

      def persist token
        remember.any?{|mem| mem === token}
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

      def remember
        [backslash]
      end
    end
  end
end
