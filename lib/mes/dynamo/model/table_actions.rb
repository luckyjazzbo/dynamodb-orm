module Mes
  module Dynamo
    class Model
      module TableActions
        attr_reader :primary_key

        def primary_key_field(name, opts = {})
          undef_field(@primary_key) if @primary_key
          @primary_key = name.to_s
          field(name, opts)
        end

        def inherited(subclass)
          # primary_key can be redefined if necessary
          subclass.primary_key_field('id')
        end

        def table_name
          @table_name || name.tableize
        end

        def table(opts = {})
          @table_name = opts[:name].to_s if opts[:name].present?
          primary_key_field(opts[:primary_key]) if opts.key? :primary_key
        end

        def field(name, settings = {})
          fields[name] = TableField.new(name, settings)
        end

        def undef_field(name)
          fields.delete(name)
        end

        def fields
          @fields ||= {}.with_indifferent_access
        end

        def table_index(hash_field, settings = {})
          index = TableIndex.new(hash_field, settings)
          table_indices[index.name] = index
        end

        def table_indices
          @table_indices ||= {}.with_indifferent_access
        end

        def create_table!
          TableCreator.new(self).create
        end

        def update_table!(force: false)
          TableUpdater.new(self).update(force: force)
        end

        def table_exists?
          describe_table.present?
        end

        def ensure_table!
          table_exists? ? update_table! : create_table!
        end

        def table_settings
          TableCreator.new(self).table_settings
        end

        def describe_table
          TableDescriber.new(self).state
        end

        def drop_table!
          client.delete_table(table_name: table_name)
        rescue ::Aws::DynamoDB::Errors::ResourceNotFoundException
          false
        end
      end
    end
  end
end
