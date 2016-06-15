module Mes
  module Dynamo
    class TableCreator
      attr_reader :model_class

      def initialize(model_class)
        @model_class = model_class
      end

      def create
        table_settings = {
          table_name:               model_class.table_name,
          attribute_definitions:    attribute_definitions,
          key_schema:               key_schema,
          provisioned_throughput:   table_provisioned_throughput
        }
        if global_secondary_indexes.present?
          table_settings[:global_secondary_indexes] = global_secondary_indexes
        end
        client.create_table(table_settings)
      end

      private

      def client
        Connection.connect
      end

      def attribute_definitions
        defs = [{ attribute_name: model_class.primary_key, attribute_type: 'S' }]
        model_class.fields.each do |field_name, field_opts|
          if field_used_in_indices?(field_name)
            defs << { attribute_name: field_name, attribute_type: field_opts[:type] }
          end
        end
        defs
      end

      def key_schema
        [{ attribute_name: model_class.primary_key, key_type: 'HASH' }]
      end

      def global_secondary_indexes
        model_class.indices.map do |index|
          {
            index_name: index.name,
            key_schema: key_schema_for(index),
            projection: { projection_type: 'ALL' },
            provisioned_throughput: index_provisioned_throughput
          }
        end
      end

      def key_schema_for(index)
        key_schema = [{ attribute_name: index.hash.to_s, key_type: 'HASH' }]
        index.range.each do |field|
          key_schema << { attribute_name: field.to_s, key_type: 'RANGE' }
        end
        key_schema
      end

      def field_used_in_indices?(field)
        model_class.indices.any? { |index| index.all_fields.include?(field.to_sym) }
      end

      def table_provisioned_throughput
        {
          read_capacity_units: 1,
          write_capacity_units: 1
        }
      end

      def index_provisioned_throughput
        {
          read_capacity_units: 1,
          write_capacity_units: 1
        }
      end
    end
  end
end
