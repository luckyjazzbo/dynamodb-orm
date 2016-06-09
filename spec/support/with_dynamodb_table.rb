RSpec.shared_context 'with dynamodb table' do |table_name, opts|
  before(:all) do
    LteCore::DynamoDB::Connection.setup(
      endpoint: ENV.fetch('DYNAMODB_ENDPOINT', 'http://dynamodb:8000')
    )
    create_table(table_name, opts)
  end

  after(:all) do
    drop_table(table_name)
  end

  before(:each) do
    truncate_table(table_name, opts)
  end
end
