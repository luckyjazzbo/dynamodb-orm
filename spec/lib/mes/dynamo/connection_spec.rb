require 'spec_helper'

RSpec.describe Mes::Dynamo::Connection do
  describe '.default_options' do
    context 'when ENV["DYNAMODB_ENDPOINT"]' do
      context "it's present" do
        let(:dynamodb_endpoint) { 'http://dynamodb:8000' }

        before do
          allow(ENV).to receive(:[])
            .with('DYNAMODB_ENDPOINT')
            .and_return(dynamodb_endpoint)
        end

        it 'returns options with endpoint' do
          expect(described_class.default_options).to eq({
            region: 'eu-west-1',
            endpoint: dynamodb_endpoint
          })
        end
      end

      context 'when blank' do
        before do
          allow(ENV).to receive(:[])
            .with('DYNAMODB_ENDPOINT')
            .and_return('')
        end

        it 'returns options without endpoint' do
          expect(described_class.default_options).to eq({
            region: 'eu-west-1'
          })
        end
      end
    end
  end
end
