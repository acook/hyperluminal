require 'yaml'
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
  attr_accessor :char, :token, :rule

  def explain
    parse.to_yaml
  end

  def parse
    debug_rule

    until eof?
      next_char! and (handle_eof! or transition! or delimit! or match!)
    end

    store_token! # save the last token
    debug_tokens # display all found tokens
    tokens       # return the token list
  end

  # event methods

  def handle_eof!
    if eof? or char.nil? then
      debug_eof
      true
    end
  end

  def transition!
    transition = rule.transition char

    if transition then
      self.rule = transition.last
      @matchers = rule.patterns

      store_token!
      debug_rule

      unless rule.delimit char then
        self.token = char
      end
    end

    !!transition
  end

  def delimit!
    if rule.delimit char then
      store_token!
      true
    end
  end

  def match!
    match

    if matchers.empty? then
      spray.pnl ''
      spray.red.pnl "Failed to match any known patterns."
      spray.pnl ''
      spray.pnl "RULE: #{rule}"
      spray.pnl "TOKEN: #{token}"
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

  def match # auto-reduce the matchers that don't work
    proposed_token = token + char
    @last_matchers = @matchers
    @matchers = rule.matches proposed_token, matchers
  end

  def matchers
    @matchers ||= rule.patterns
  end

  # storage methods

  def store_token!
    unless token.empty? then
      debug_token

      tokens << token
      self.token = String.new
    end
  end

  def store_char!
    token << char
  end

  # debugging methods

  def debug_char
    spray.p char
  end

  def debug_rule
    spray.green.pnl "RULE: #{rule.identifier}"
  end

  def debug_token
    spray.green.pnl "TOKEN: #{token}"
  end

  def debug_tokens
    spray.green.pnl "TOKENS(#{tokens.length}): #{tokens}"
  end

  def debug_eof
    spray.red.pnl "EOF: #{eof?} CHAR: #{char.is_a?(String) ? "\"#{char}\"" : char.inspect }"
  end

  # attribute methods

  def token
    @token ||= String.new
  end

  def rule
    @rule ||= Rules.root
  end

  private

  def spray
    @spray ||= Spray.new
  end

  def next_char!
    begin
      self.char = source.readchar
    rescue EOFError
      self.char = nil
      eof!
      source.close
    end

    if char then
      self.buffer << char
      self.offset += 1

      debug_char

      char
    end
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
