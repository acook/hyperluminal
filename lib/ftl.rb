require 'bundler'

Bundler.setup

require 'pry'

$ftl_root = Pathname.new(__FILE__).dirname.expand_path
$LOAD_PATH << $ftl_root.to_s

#dirs = [root.join('explainers', '*.rb'), root.join('nodes', '*.rb')]
#Dir[*dirs].each {|file| require file }

require 'hyperluminal'
require 'hyperluminal/version'

module FTL
  extend self

  def dump file
    raise NotImplementedError
  end

  def exe file
    raise NotImplementedError
  end

  def explain file
    Hyperluminal.parse(file).explain
  end
end
