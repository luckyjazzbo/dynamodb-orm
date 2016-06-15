module Mes
  module Dynamo
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

      def count
        client_execute(:describe_table, {}).table.item_count
      end

      def chain(opts = {})
        Chain.new(self, opts)
      end

      def chain_with_scan
        chain(scan: true)
      end
    end
  end
end
