require 'pathname'
require_relative '../../lib/support/exe'

module Helpers
  def cmp? path_to_example
    ftl_output  = ftl(path_to_example).output
    example_txt = Pathname.new(path_to_example).sub_ext('.txt').read
    expect(ftl_output).to eq example_txt
  end

  def cmp path_to_example
    ftl_output  = ftl(path_to_example).output
    example_txt = Pathname.new(path_to_example).sub_ext('.txt').read
    {expected: example_txt, actual: ftl_output}
  end

  def ftl file
    exe "#{bin} exe #{file}"
  end

  def exe command
    Exe.new(command).run
  end

  def bin
    pwd.join 'bin', 'ftl'
  end

  def examples
    Dir[example_path.join '*.ftl']
  end

  def example name
    example_path.join name
  end

  def example_path
    pwd.join 'spec', 'examples'
  end

  def pwd
    $pwd ||= Pathname.new(__FILE__).expand_path.dirname.parent.parent
  end
end

Object.new.tap{|o| o.extend(Helpers)}.pwd
