require_relative 'spec_helper'
require 'pry'
describe 'Examples' do
  let(:expected){ Array.new }
  let(:actual){   Array.new }

  let(:run_examples) do
    examples.each do |example|
      result = cmp example
      expected << result[:expected]
      actual   << result[:actual]
    end
  end

  specify 'examples equal their output' do
    run_examples
    expect(actual).to eq expected
  end
end
