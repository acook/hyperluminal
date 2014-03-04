require 'rubygems'
require 'treetop'
require 'pry'

root = Pathname.new(__FILE__).dirname.expand_path
$LOAD_PATH << root.to_s

dirs = [root.join('explainers', '*.rb'), root.join('nodes', '*.rb')]
Dir[*dirs].each {|file| require file }

require_relative 'grammar'

module FTL
  extend self
  extend BasicExplainer

  def explain text
    decide_explain parse text
  end

  def parse text
    Grammar.parse text
  end
end

