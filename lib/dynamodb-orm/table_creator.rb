module DynamodbOrm
  class TableCreator
    attr_reader :model_class

    def initialize(model_class)
      @model_class = model_class
    end

    def create
      client.create_table(table_settings)
    end

    def table_settings
      @table_settings ||= {
        table_name:               model_class.table_name,
        attribute_definitions:    attribute_definitions,
        key_schema:               key_schema,
        provisioned_throughput:   table_provisioned_throughput
      }.tap do |settings|
        if global_secondary_indexes.present?
          settings[:global_secondary_indexes] = global_secondary_indexes
        end
      end
    end

    private

    def client
      Connection.connect
    end

    def attribute_definitions
      defs = [{ attribute_name: model_class.primary_key, attribute_type: 'S' }]
      model_class.fields.values.each do |field|
        if field_used_in_indices?(field.name)
          defs << { attribute_name: field.name.to_s, attribute_type: field.dynamodb_type }
        end
      end
      defs.sort_by {|ad| ad[:attribute_name]}
    end

    def key_schema
      [{ attribute_name: model_class.primary_key, key_type: 'HASH' }]
    end

    def global_secondary_indexes
      model_class.table_indices.map do |_, index|
        {
          index_name: index.name,
          key_schema: key_schema_for(index),
          projection: { projection_type: 'ALL' },
          provisioned_throughput: index_provisioned_throughput(index.name)
        }
      end.sort_by { |index| index[:index_name] }
    end

    def key_schema_for(index)
      key_schema = [{ attribute_name: index.hash.to_s, key_type: 'HASH' }]
      index.range.each do |field|
        key_schema << { attribute_name: field.to_s, key_type: 'RANGE' }
      end
      key_schema
    end

    def field_used_in_indices?(field)
      model_class.table_indices.any? { |_, index| index.all_fields.include?(field) }
    end

    def table_provisioned_throughput
      DynamodbOrm.provisioning_config
                 .fetch(env_insensitive_table_name)
                 .except('indices')
                 .symbolize_keys
    end

    def index_provisioned_throughput(index_name)
      DynamodbOrm.provisioning_config
                 .fetch(env_insensitive_table_name)
                 .fetch('indices')
                 .fetch(index_name)
                 .symbolize_keys
    end

    def env_insensitive_table_name
      model_class.table_name.gsub("-#{RACK_ENV}", '')
    end
  end
end
