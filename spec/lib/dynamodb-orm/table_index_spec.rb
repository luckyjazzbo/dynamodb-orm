require 'spec_helper'

RSpec.describe DynamodbOrm::TableIndex do
  let(:name)        { 'test_index' }
  let(:hash)        { 'test_hash_field' }
  let(:range)       { 'test_range_field' }
  let(:range_array) { %w(test_range_field test_range_field_2) }

  describe '#hash' do
    subject { described_class.new(hash, {}) }

    it 'saves hash key' do
      expect(subject.hash).to eq(hash.to_sym)
    end
  end

  describe '#range' do
    context 'when a single field' do
      subject { described_class.new(hash, range: range) }

      it 'saves range key as array of symbols' do
        expect(subject.range).to eq([range.to_sym])
      end
    end

    context 'when multiple fields' do
      subject { described_class.new(hash, range: range_array) }

      it 'saves range key as array of symbols' do
        expect(subject.range).to eq(range_array.map(&:to_sym))
      end
    end
  end

  describe '#name' do
    context 'when passed as a setting' do
      subject { described_class.new(hash, name: name) }

      it 'saves the name' do
        expect(subject.name).to eq(name)
      end
    end

    context 'when does not passed' do
      subject { described_class.new(hash, {}) }

      it 'generates default name' do
        expect(subject.name).to eq("#{hash}_index")
      end
    end
  end

  describe '#all_fields' do
    subject { described_class.new(hash, range: range) }

    it 'returns all key fields as array of symbols' do
      expect(subject.all_fields).to eq([hash.to_sym, range.to_sym])
    end
  end
end
