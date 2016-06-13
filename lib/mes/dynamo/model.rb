module Mes
  module Dynamo
    module Model
      include Enumerable

      attr_reader :attributes

      def initialize(attrs = {}, opts = {})
        @attributes = (attrs || {}).stringify_keys
        @persisted = opts.fetch(:persisted, false)
      end

      def persisted?
        @persisted
      end

      def primary_key
        read_attribute(cls.primary_key)
      end

      def read_attribute(name)
        attributes[name.to_s]
      end

      def write_attribute(name, value)
        attributes[name.to_s] = value if has_attribute?(name)
      end

      def has_attribute?(name)
        (cls.primary_key == name.to_s) || (cls.fields && cls.fields.key?(name.to_s))
      end

      def assign_attributes(attributes)
        attributes.each do |name, value|
          write_attribute(name, value)
        end
      end

      def update_attributes(attributes)
        cls.run_callbacks(self, :before_update)
        assign_attributes(attributes)
        save
      end

      def save!
        cls.run_callbacks(self, :before_create) unless persisted?
        cls.run_callbacks(self, :before_save)
        cls.client_execute(:put_item, item: attributes)
        @persisted = true
      end

      def save
        save!
      rescue Dynamo::GenericError
        false
      end

      def delete
        cls.run_callbacks(self, :before_delete)
        cls.client_execute(:delete_item, key: { cls.primary_key => primary_key })
        attributes.slice!(cls.primary_key)
        @persisted = false
      end

      def method_missing(name, *args)
        if has_attribute?(name)
          read_attribute(name)
        elsif attribute_setter?(name)
          write_attribute normalize_name(name), args[0]
        else
          super
        end
      end

      private

      def attribute_setter?(name)
        name = name.to_s
        name[-1] == '=' && has_attribute?(name[0..-2])
      end

      def normalize_name(name)
        attribute_setter?(name) ? name.to_s[0..-2] : name.to_s
      end

      def cls
        self.class
      end

      def self.included(base)
        base.extend(ClassMethods)
        base.extend(Callbacks)
        base.table
      end

      module ClassMethods
        attr_reader :table_name,
                    :primary_key,
                    :fields

        delegate :where, :index, to: :chain
        delegate :each, :first, to: :chain_with_scan

        def table(opts = {})
          @table_name = opts.fetch(:name, name.tableize).to_s
          @primary_key = opts.fetch(:primary_key, 'content_id').to_s
        end

        def field(name, opts = {})
          @fields ||= {}
          @fields[name.to_s] = opts
        end

        def create!(attributes)
          new(attributes).tap(&:save!)
        end

        def find(id)
          response = client_execute(:get_item, key: { primary_key => id })
          response.item.blank? ? nil : new(response.item, persisted: true)
        end

        def find!(id)
          find(id).tap do |model|
            raise RecordNotFound, "Unable to find record with key: '#{id}'" unless model
          end
        end

        def count
          client_execute(:describe_table, {}).table.item_count
        end

        def chain(opts = {})
          Chain.new(self, opts)
        end

        def chain_with_scan
          chain(scan: true)
        end
        private :chain_with_scan

        def truncate!
          each(&:delete)
        end

        def client
          @client ||= Connection.connect
        end

        def client_execute(method, opts)
          default_options = { table_name: table_name }
          final_options = default_options.merge(opts)
          ::Mes::Dynamo.logger.debug "Request: #{final_options.inspect}"

          execute do
            client.send method, final_options
          end
        end

        def execute(&block)
          instance_exec(&block)
        rescue Aws::DynamoDB::Errors::ServiceError => origin_error
          raise Mes::Dynamo::GenericError.mes_error_for(origin_error)
        end
      end
    end
  end
end
