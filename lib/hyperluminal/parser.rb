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
        @matchers = current_rule.patterns
        debug_rule

        store_token!

        unless current_rule.delimit current_char then
          self.current_token = current_char
        end
      elsif current_rule.delimit current_char then
        store_token!
      elsif !eof? then
        match!

        if matchers.empty? then
          spray.pnl ''
          spray.red.pnl "Failed to match any known patterns."
          spray.pnl ''
          spray.pnl "RULE: #{current_rule}"
          spray.pnl "TOKEN: #{current_token}"
          spray.pnl "OFFSET: #{offset}"
          spray.pnl "LAST MATCHERS: #{@last_matchers}"
          spray.pnl ''
          spray.pnl "BUFFER: #{buffer.inspect}"
          spray.pnl ''

          raise 'PARSE FAILED'
        else
          store_char!
        end
      end
    end

    store_token!

    debug_tokens
    tokens.inspect
  end

  def store_token!
    unless current_token.empty? then
      debug_token

      tokens << current_token
      self.current_token = String.new
    end
  end

  def store_char!
    current_token << current_char
  end

  def match! # auto-reduce the matchers that don't work
    proposed_token = current_token + current_char
    @last_matchers = @matchers
    @matchers = current_rule.matches proposed_token, matchers
  end

  def matchers
    @matchers ||= current_rule.patterns
  end

  def debug_char
    spray.p current_char
  end

  def debug_rule
    spray.green.pnl "RULE: #{current_rule.identifier}"
  end

  def debug_token
    spray.green.pnl "TOKEN: #{current_token}"
  end

  def debug_tokens
    spray.green.pnl "TOKENS(#{tokens.length}): #{tokens}"
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

      def matches token, matchers = patterns
        return false if token.nil?
        matchers.select{|pattern| pattern === token }
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
          SmallWord.patterns.first => SmallWord,
          single_quote => SingleQuotedText
        }
      end

      def delimiters
        [space, newline, single_quote]
      end
    end

    module SmallWord
      extend Rule
      extend self

      def transitions
        antipatterns_to_transitions.merge delimiters_to_transitions
      end

      def patterns
        [/[a-z]/]
      end

      def antipatterns_to_transitions
        patterns.inject Hash.new do |t, p|
          t[/[^#{p.source}]/] = Root
          t
        end
      end

      def delimiters_to_transitions
        delimiters.inject Hash.new do |t, d|
          t[d] = Root
          t
        end
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

      def delimiters
        [single_quote]
      end
    end
  end
end
