require_relative 'spec_helper'

class FTL
  class << self
    def explain text
      text
    end
  end
end

describe 'Basic Syntax' do
  it 'can set variables' do
    result = FTL.explain 'one: 1'
    expect(result).to eq "<variable one>: <Number 1>"
  end

  describe 'Literals' do
    it 'can interpret single integer literals' do
      result = FTL.explain '1'
      expect(result).to eq '<Number 1>'
    end
  end
end
