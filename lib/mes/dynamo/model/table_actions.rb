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

      def field(name, opts = {})
        fields[name.to_sym] = opts
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

      def create
        ::Mes::Dynamo::TableCreator.new(self).create
      end

      def drop!
        client.delete_table(table_name: table_name)
      rescue Aws::DynamoDB::Errors::ResourceNotFoundException
        false
      end
    end
  end
end
