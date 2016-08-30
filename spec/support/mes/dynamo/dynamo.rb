module DynamoDBSpecHelpers
  def create_table(table_name, opts)
    dynamodb_client.create_table(
      opts.merge(
        table_name: table_name,
        provisioned_throughput: { read_capacity_units: 1, write_capacity_units: 1 }
      )
    )
    wait_till_table_create(table_name)
  end

  def drop_table(table_name)
    dynamodb_client.delete_table(table_name: table_name) if table_exists?(table_name)
  end

  def drop_all_tables
    response = dynamodb_client.list_tables
    response.table_names.each do |table_name|
      drop_table(table_name)
    end
  end

  def describe_table(table_name)
    dynamodb_client.describe_table(table_name: table_name).table.to_h
  end

  def table_exists?(table_name)
    describe_table(table_name)[:table_status] == 'ACTIVE'
  rescue ::Aws::DynamoDB::Errors::ResourceNotFoundException
    false
  end

  def wait_till_table_create(table_name)
    100.times do
      break if table_exists?(table_name)
      sleep 0.02
    end
  end

  def min_provisioning
    { 'read_capacity_units' => 1, 'write_capacity_units' => 1 }
  end

  def define_provisioning_for(model)
    name = model.table_name.gsub("-#{RACK_ENV}", '')
    Mes::Dynamo::PROVISIONING_CONFIG[name] = min_provisioning
    model.table_indices.each do |_, index|
      Mes::Dynamo::PROVISIONING_CONFIG[name]['indices'] ||= {}
      Mes::Dynamo::PROVISIONING_CONFIG[name]['indices'][index.name] = min_provisioning
    end
  end

  def truncate_table(table_name, opts)
    primary_key = opts[:key_schema][0][:attribute_name]
    response = dynamodb_client.scan(
      table_name: table_name,
      attributes_to_get: [primary_key],
      select: 'SPECIFIC_ATTRIBUTES'
    )
    response.items.each do |item|
      dynamodb_client.delete_item(
        table_name: table_name,
        key: { primary_key => item[primary_key] }
      )
    end
  end

  private

  def dynamodb_client
    Mes::Dynamo::Connection.connect
  end
end

RSpec.configure do |config|
  config.include DynamoDBSpecHelpers
end
