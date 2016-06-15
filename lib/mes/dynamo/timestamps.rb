module Mes
  module Dynamo
    module Timestamps
      def self.included(base)
        base.field :created_at, type: 'N'
        base.field :updated_at, type: 'N'

        base.before_update do
          self.updated_at = current_time
        end

        base.before_create do
          self.created_at = current_time
          self.updated_at = current_time
        end
      end

      private

      def current_time
        Time.now.to_i
      end
    end
  end
end
