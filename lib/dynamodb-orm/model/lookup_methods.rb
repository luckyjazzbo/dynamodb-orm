module DynamodbOrm
  class Model
    module LookupMethods
      delegate :where, :index, to: :chain
      delegate :each, :first, :limit, to: :chain_with_scan

      def find(id)
        response = client_execute(:get_item, key: { primary_key => id })
        response.item.blank? ? nil : new(response.item, persisted: true)
      end

      def find!(id)
        find(id).tap do |model|
          raise RecordNotFound, "Unable to find record with key: '#{id}'" unless model
        end
      end

      def find_by(column, value)
        index("#{column}_index").where(column => value)
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

      module InstanceMethods
        def reload!
          raise InvalidQuery, 'Cannot reload an object without primary key' if id.blank?
          response = cls.client_execute(:get_item, key: { cls.primary_key => public_send(cls.primary_key) })
          init_attributes(response.item)
          self
        end
      end
    end
  end
end
