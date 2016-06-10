require 'with_dynamodb_table'

RSpec.shared_context 'with original_resources' do
  include_context 'with dynamodb table',
    OriginalResource.table_name,
    attribute_definitions: [{
      attribute_name: 'uuid', attribute_type: 'S'
    }, {
      attribute_name: 'content_id',
      attribute_type: 'S'
    }],
    key_schema: [{
      attribute_name: 'uuid', key_type: 'HASH'
    }],
    global_secondary_indexes: [{
      index_name: 'content_id_index',
      key_schema: [{
        attribute_name: 'content_id',
        key_type: 'HASH'
      }],
      projection: {
        projection_type: 'ALL'
      },
      provisioned_throughput: {
        read_capacity_units: 1,
        write_capacity_units: 1
      }
    }]
end
