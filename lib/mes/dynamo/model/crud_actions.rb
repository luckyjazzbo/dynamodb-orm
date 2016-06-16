module Mes
  module Dynamo
    class Model
      module CRUDActions
        extend ActiveSupport::Concern

        def persisted?
          @persisted
        end

        def persist!
          @persisted = true
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
          persist!
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

        class_methods do
          def create!(attributes)
            new(attributes).tap(&:save!)
          end

          def truncate!
            each(&:delete)
          end
        end
      end
    end
  end
end
