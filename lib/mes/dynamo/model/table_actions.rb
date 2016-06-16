module Mes
  module Dynamo
    module TableActions
      def table_name
        @table_name || name.tableize
      end

      def primary_key
        @primary_key || 'content_id'
      end

      def table(opts = {})
        @table_name  = opts[:name].to_s        if opts[:name].present?
        @primary_key = opts[:primary_key].to_s if opts[:primary_key].present?
      end

      def field(name, settings = {})
        fields[name] = TableField.new(name, settings)
      end

      def fields
        @fields ||= {}.with_indifferent_access
      end

      def index(hash_field, settings = {})
        indices << TableIndex.new(hash_field, settings)
      end

      def indices
        @indices ||= []
      end

      def create_table!
        TableCreator.new(self).create
      end

      def drop_table!
        client.delete_table(table_name: table_name)
      rescue Aws::DynamoDB::Errors::ResourceNotFoundException
        false
      end
    end
  end
end
