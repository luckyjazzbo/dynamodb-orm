require 'with_dynamodb_table'

RSpec.shared_context 'with transformed_resources' do
  include_context 'with dynamodb table',
    TransformedResource.table_name,
    attribute_definitions: [{
      attribute_name: 'content_id', attribute_type: 'S'
    }],
    key_schema: [{
      attribute_name: 'content_id', key_type: 'HASH'
    }]
end
