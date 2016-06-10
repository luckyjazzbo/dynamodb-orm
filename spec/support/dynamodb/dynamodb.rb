module DynamoDBSpecHelpers
  def create_table(table_name, opts)
    check_schema(opts[:attribute_definitions])
    check_schema(opts[:key_schema])

    client.create_table(
      {
        table_name: table_name,
        provisioned_throughput: {
          read_capacity_units: 1,
          write_capacity_units: 1
        }
      }.merge(opts)
    )
    wait_till_table_create(table_name)
  end

  def drop_table(table_name)
    client.delete_table(table_name: table_name)
  end

  def wait_till_table_create(table_name)
    created = false
    while !created
      resp = client.describe_table(
        table_name: table_name
      )
      created = true if resp.table.table_status == 'ACTIVE'
    end
  end

  def truncate_table(table_name, opts)
    primary_key = opts[:key_schema][0][:attribute_name]
    response = client.scan(
      table_name: table_name,
      attributes_to_get: [primary_key],
      select: 'SPECIFIC_ATTRIBUTES'
    )
    response.items.each do |item|
      client.delete_item(
        table_name: table_name,
        key: { primary_key => item[primary_key] }
      )
    end
  end

  private

  def client
    LteCore::DynamoDB::Connection.connect
  end

  def check_schema(array)
    if !array.is_a?(Array)
      raise ArgumentError, 'schema should be an array'
    end

    if array.any? { |el| !el.is_a?(Hash) }
      raise ArgumentError, 'all elements should be hashes'
    end
  end
end

RSpec.configure do |config|
  config.include DynamoDBSpecHelpers
end
