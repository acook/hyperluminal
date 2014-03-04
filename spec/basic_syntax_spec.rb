require_relative 'spec_helper'

describe 'Basic Syntax Parsing' do
  describe 'Assignment' do
    it 'can set variables with spaces' do
      result = FTL.explain 'one: 1'
      expect(result).to eq '<Assignment <SetwordLocal one><NumberLiteral 1>>'
    end

    it 'can set variables without spaces' do
      result = FTL.explain 'one:1'
      expect(result).to eq '<Assignment <SetwordLocal one><NumberLiteral 1>>'
    end

    it 'can set pathable variables' do
      result = FTL.explain 'One: 1'
      expect(result).to eq '<Assignment <SetwordPathable One><NumberLiteral 1>>'
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
      it 'empty string' do
        result = FTL.explain '""'
        expect(result).to eq '<TextLiteral "">'
      end

      it 'single word double quoted strings' do
        result = FTL.explain '"something"'
        expect(result).to eq '<TextLiteral "something">'
      end

      it 'multi-word double quoted strings' do
        result = FTL.explain '"something else huh"'
        expect(result).to eq '<TextLiteral "something else huh">'
      end
    end

    describe 'Sequences' do
      it 'empty list' do
        result = FTL.explain '()'
        expect(result).to eq '<SequenceLiteral ()>'
      end

      it 'single element list' do
        result = FTL.explain '(1)'
        expect(result).to eq '<SequenceLiteral <NumberLiteral 1>>'
      end

      it 'multi-element list' do
        result = FTL.explain '(1 2 3)'
        expect(result).to eq '<SequenceLiteral <NumberLiteral 1><NumberLiteral 2><NumberLiteral 3>>'
      end
    end

    describe 'Dictionaries' do
      it 'single pair hash' do
        result = FTL.explain '(abc:2)'
        expect(result).to eq '<DictionaryLiteral <PairLiteral <SetwordLocal abc><NumberLiteral 2>>>'
      end

      it 'multi-pair hash' do
        result = FTL.explain '(abc:2 gdf:100)'
        expect(result).to eq '<DictionaryLiteral <PairLiteral <SetwordLocal abc><NumberLiteral 2>><PairLiteral <SetwordLocal gdf><NumberLiteral 100>>>'
      end
    end
  end
end
