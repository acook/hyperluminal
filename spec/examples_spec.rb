require_relative 'spec_helper'

describe 'Examples' do
  specify 'examples equal their output' do
    examples.each do |example|
      cmp? example
    end
  end
end
