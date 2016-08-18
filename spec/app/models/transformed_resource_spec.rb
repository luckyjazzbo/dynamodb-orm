require 'spec_helper'

RSpec.describe Mes::TransformedResource do
  include_context 'with mes tables'

  describe '#asset_type' do
    context 'by default' do
      it 'expected to be nil' do
        expect(subject.asset_type).to be_nil
      end
    end

    context 'when present' do
      subject { described_class.new(data: { 'asset_type' => 'video' }) }

      it 'is not nil' do
        expect(subject.asset_type).to eq('video')
      end
    end
  end

  describe '.create_from_original_resource!' do
    let(:original_resource) { FactoryGirl.create(:original_resource) }
    let(:data) { { 'test_field' => 'test data' } }

    subject { described_class.create_from_original_resource!(original_resource, data) }

    it 'saves OriginalResource as TransformedResource' do
      expect { subject }.to change(Mes::TransformedResource, :count).by(1)
    end

    it 'creates valid object from original_resource' do
      expect(subject.attributes.slice('content_id', 'original_resource_uuid', 'data')).to eq(
        'content_id'             => original_resource.content_id,
        'original_resource_uuid' => original_resource.uuid,
        'data'                   => data
      )
    end
  end
end
