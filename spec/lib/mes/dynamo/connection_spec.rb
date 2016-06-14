require 'spec_helper'

RSpec.describe Mes::Dynamo::Connection do
  describe '.default_options' do
    context 'when ENV["DYNAMODB_ENDPOINT"]' do
      context 'it\'s present' do
        it 'returns options with endpoint' do
          ENV['DYNAMODB_ENDPOINT'] = 'http://dynamodb:8000'

          expect(described_class.default_options).to eq(
            {
              region: 'eu-west-1',
              endpoint: ENV['DYNAMODB_ENDPOINT']
            }
          )
        end
      end

      context 'when blank' do
        it 'returns options without endpoint' do
          ENV['DYNAMODB_ENDPOINT'] = ''

          expect(described_class.default_options).to eq(
            {
              region: 'eu-west-1'
            }
          )
        end
      end
    end
  end
end
