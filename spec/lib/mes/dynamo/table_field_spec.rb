require 'spec_helper'

RSpec.describe Mes::Dynamo::TableField do
  let(:name) { 'test_field' }

  describe '#name' do
    subject { described_class.new(name, {}) }

    it 'saves the name' do
      expect(subject.name).to eq(name.to_sym)
    end
  end

  describe '#type' do
    context 'when type exists' do
      context 'when symbol' do
        subject { described_class.new(name, type: :string) }

        it 'saves the type' do
          expect(subject.type).to eq(:string)
        end
      end

      context 'when string' do
        subject { described_class.new(name, type: 'string') }

        it 'saves the type' do
          expect(subject.type).to eq(:string)
        end
      end
    end

    context 'when type does not exist' do
      subject { described_class.new(name, type: :invalid_type) }

      it 'saves the type' do
        expect { subject }.to raise_error(Mes::Dynamo::InvalidFieldType)
      end
    end
  end

  describe '#dynamodb_type' do
    subject { described_class.new(name, type: :string) }

    it 'converts type to appropriate dynamodb type' do
      expect(subject.dynamodb_type).to eq('S')
    end
  end
end
