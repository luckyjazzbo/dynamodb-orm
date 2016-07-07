module Mes
  module Dynamo
    module SoftDeletion
      extend ActiveSupport::Concern

      def self.included(base)
        base.field :deleted_at, type: :number, default: 0
        base.alias_method_chain :delete, :soft_deletion

        base.class_eval do
          class << self
            %w(count chain table_index index find).each do |method|
              alias_method_chain method, :soft_deletion
            end
          end

          table_index_without_soft_deletion :deleted_at, projection: 'KEYS_ONLY'
        end
      end

      def deleted?
        deleted_at > 0
      end

      def delete_with_soft_deletion
        cls.run_callbacks(self, :before_delete)
        update_attributes(deleted_at: current_time)
        @persisted = false
      end

      class_methods do
        def chain_with_soft_deletion(opts = {})
          chain_without_soft_deletion(opts)
            .index('deleted_at_index')
            .where('deleted_at = :zero', zero: 0)
        end

        def count_with_soft_deletion
          chain_with_soft_deletion.count
        end

        def find_with_soft_deletion(id)
          find_without_soft_deletion(id).tap do |item|
            return nil if item.nil? || item.deleted?
          end
        end

        def index_with_soft_deletion(name)
          chain_without_soft_deletion.index(name).where('deleted_at = :zero', zero: 0)
        end

        def table_index_with_soft_deletion(hash_field, settings = {})
          settings[:name] ||= TableIndex.new(hash_field, settings).name
          settings[:range] ||= []
          settings[:range] << :deleted_at
          table_index_without_soft_deletion(hash_field, settings)
        end
      end

      private

      def current_time
        # DynamoDB gem stores numbers as BigDecimal
        ::BigDecimal.new Time.now.to_f, 16
      end
    end
  end
end
