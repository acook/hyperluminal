require_relative 'spec_helper'

describe 'Basic Syntax' do
  describe 'Setwords' do
    it 'can set variables with spaces' do
      result = FTL.explain 'one: 1'
      expect(result).to eq '<Setword one><NumberLiteral 1>'
    end

    it 'can set variables without spaces' do
      result = FTL.explain 'one:1'
      expect(result).to eq '<Setword one><NumberLiteral 1>'
    end
  end

  describe 'Literals' do
    describe 'Numbers' do
      it 'single number integers' do
        result = FTL.explain '1'
        expect(result).to eq '<NumberLiteral 1>'
      end

      it 'multiple number integers' do
        result = FTL.explain '510'
        expect(result).to eq '<NumberLiteral 510>'
      end
    end

    describe 'Text' do
      it 'single word double quoted strings' do
        result = FTL.explain '"something"'
        expect(result).to eq '<TextLiteral "something">'
      end

      it 'multi-word double quoted strings' do
        result = FTL.explain '"something else huh"'
        expect(result).to eq '<TextLiteral "something else huh">'
      end
    end
  end
end
