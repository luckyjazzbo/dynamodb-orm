module Mes
  module Dynamo
    module AllowsSoftDeletion
      def acts_as_soft_deletable(opts = {})
        include SoftDeletion.new(opts)
      end
    end

    class SoftDeletion < Module
      def initialize(opts = {})
        @deleted_at_key = opts.fetch(:field, :deleted_at)
      end

      def included(base)
        base.send :extend, ClassMethods
        base.deleted_at_key = @deleted_at_key
        base.include InstanceMethods
      end

      module InstanceMethods
        def deleted_at_key
          self.class.deleted_at_key
        end

        def deleted?
          read_attribute(deleted_at_key) > 0
        end

        def delete_with_soft_deletion
          cls.run_callbacks(self, :before_delete)
          update_attributes(deleted_at_key => current_time)
          @persisted = false
        end

        def self.included(base)
          base.class_eval do
            class << self
              %w(count chain table_index index find).each do |method|
                alias_method_chain method, :soft_deletion
              end
            end
            table_index_without_soft_deletion deleted_at_key, projection: 'KEYS_ONLY'
            field deleted_at_key, type: :float, default: 0
            alias_method_chain :delete, :soft_deletion
          end
        end

        private

        def current_time
          Time.now.to_f
        end
      end

      module ClassMethods
        attr_accessor :deleted_at_key

        def chain_with_soft_deletion(opts = {})
          chain_with_deleted_items("#{deleted_at_key}_index", opts)
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
          chain_with_deleted_items(name)
        end

        def table_index_with_soft_deletion(hash_field, settings = {})
          settings[:name]  ||= TableIndex.new(hash_field, settings).name
          settings[:range] ||= [deleted_at_key]
          table_index_without_soft_deletion(hash_field, settings)
        end

        private

        def chain_with_deleted_items(index_name, chain_opts = {})
          chain = chain_without_soft_deletion(chain_opts).index(index_name)

          if table_indices[index_name].has_key?(deleted_at_key)
            chain.where("#{deleted_at_key} = :zero", zero: 0)
          else
            chain.filter("#{deleted_at_key} = :zero", zero: 0)
          end
        end
      end
    end
  end
end
