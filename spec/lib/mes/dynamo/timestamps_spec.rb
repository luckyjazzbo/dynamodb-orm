require 'spec_helper'

RSpec.describe Mes::Dynamo::Timestamps do
  include_context(
    'with dynamodb table',
    'sample_objects',
    attribute_definitions: [{
      attribute_name: 'uuid',
      attribute_type: 'S'
    }],
    key_schema: [{
      attribute_name: 'uuid',
      key_type: 'HASH'
    }]
  )

  class SampleObject < Mes::Dynamo::Model
    include Mes::Dynamo::Timestamps
    table name: 'sample_objects', primary_key: :uuid
  end

  describe '#created_at' do
    context 'when object is new' do
      subject { SampleObject.new(uuid: SecureRandom.uuid) }

      it 'is being initialized' do
        expect {
          subject.save!
        }.to change {
          subject.created_at
        }.from(nil)
      end
    end

    context 'when object is saved' do
      subject { SampleObject.create!(uuid: SecureRandom.uuid) }

      it 'is present' do
        expect(subject.created_at).to be_present
      end

      it 'returns Float' do
        expect(subject.created_at).to be_a(Float)
      end

      it 'returns Float after reload' do
        expect(SampleObject.find(subject.uuid).created_at).to be_a(Float)
      end

      it 'does not change on saves' do
        expect {
          subject.save!
        }.not_to change {
          subject.created_at
        }
      end
    end
  end

  describe '#updated_at' do
    context 'when object is new' do
      subject { SampleObject.new(uuid: SecureRandom.uuid) }

      it 'is being initialized' do
        expect {
          subject.save!
        }.to change {
          subject.updated_at
        }.from(nil)
      end
    end

    context 'when object is saved' do
      subject { SampleObject.create!(uuid: SecureRandom.uuid) }

      it 'is present' do
        expect(subject.updated_at).to be_present
      end

      it 'returns Float' do
        expect(subject.updated_at).to be_a(Float)
      end

      it 'returns Float after reload' do
        expect(SampleObject.find(subject.uuid).updated_at).to be_a(Float)
      end

      it 'changes on saves' do
        expect {
          sleep 0.01
          subject.save!
        }.to change {
          subject.updated_at
        }
      end
    end
  end
end
