require 'spec_helper'

RSpec.describe Mes::ContentIdServiceClient do
  let(:access_token) { 'x-123' }

  subject { described_class.new('http://example.com') }

  before do
    stub_request(:get, 'http://example.com/v1/next_ids/access_token/1')
      .to_return(body: { 'ids' => [access_token] }.to_json)
  end

  describe '#next_access_token_id' do
    it 'returns correct value' do
      expect(subject.next_access_token_id).to eq(access_token)
    end
  end
end
