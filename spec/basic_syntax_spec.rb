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
    expect(result).to eq '<variable one>: <Integer 1>'
  end

  describe 'Literals' do
    describe 'Numbers' do
      it 'single number integers' do
        result = FTL.explain '1'
        expect(result).to eq '<Integer 1>'
      end

      it 'multiple number integers' do
        result = FTL.explain '510'
        expect(result).to eq '<Integer 510>'
      end
    end

    describe 'Text' do
      it 'single word double quoted strings' do
        result = FTL.explain '"something'
        expect(result).to eq '<Text "something">'
      end

      it 'multi-word double quoted strings' do
        result = FTL.explain '"something else huh'
        expect(result).to eq '<Text "something else huh">'
      end
    end
  end
end
