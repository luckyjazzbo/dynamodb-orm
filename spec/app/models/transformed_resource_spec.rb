require 'spec_helper'

RSpec.describe Mes::TransformedResource do
  include_context 'with mes tables'

  describe '.create_from_original_resource!' do
    let(:original_resource) { FactoryGirl.create(:original_resource) }
    let(:data) { { 'test_field' => 'test data' } }

    subject { described_class.create_from_original_resource!(original_resource, data) }

    it 'saves OriginalResource as TransformedResource' do
      expect { subject }.to change(Mes::TransformedResource, :count).by(1)
    end

    it 'creates valid object from original_resource' do
      expect(subject.attributes.except('uuid', 'created_at', 'updated_at')).to eq(
        'asset_type'             => original_resource.data['asset_type'],
        'content_id'             => original_resource.content_id,
        'original_resource_uuid' => original_resource.uuid,
        'data'                   => data
      )
    end
  end
end
