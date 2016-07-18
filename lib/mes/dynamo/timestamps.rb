module Mes
  module Dynamo
    module Timestamps
      def self.included(base)
        base.field :created_at, type: :float
        base.field :updated_at, type: :float

        base.before_create do
          self.created_at = current_time
        end

        base.before_save do
          self.updated_at = current_time
        end
      end

      private

      def current_time
        Time.now.to_f
      end
    end
  end
end
