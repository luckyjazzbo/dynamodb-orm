module Mes
  module Dynamo
    class TableDescriber
      attr_reader :model_class

      FIELDS = [
        :table_name,
        :provisioned_throughput,
        :attribute_definitions,
        :key_schema,
        :global_secondary_indexes
      ].freeze

      def initialize(model_class)
        @model_class = model_class
      end

      def state
        client
          .describe_table(table_name: model_class.table_name).table.to_h
          .slice(*FIELDS)
          .tap do |desc|
          desc[:attribute_definitions].try(:sort_by!) { |ad| ad[:attribute_name] }
          desc[:global_secondary_indexes].try(:sort_by!) { |index| index[:index_name] }
          desc[:provisioned_throughput].slice!(:read_capacity_units, :write_capacity_units)

          desc[:global_secondary_indexes].try(:each) do |index|
            index.slice!(:index_name, :key_schema, :projection, :provisioned_throughput)
            index[:provisioned_throughput].slice!(:read_capacity_units, :write_capacity_units)
          end
        end
      rescue Aws::DynamoDB::Errors::ResourceNotFoundException
        nil
      end

      private

      def client
        Connection.connect
      end
    end
  end
end
