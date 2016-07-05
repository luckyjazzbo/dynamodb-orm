module Mes
  module Dynamo
    module Timestamps
      def self.included(base)
        base.field :created_at, type: :number
        base.field :updated_at, type: :number

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
        # DynamoDB gem stores numbers as BigDecimal
        ::BigDecimal.new Time.now.to_f, 16
      end

      def created_at
        attributes['created_at'].to_f if attributes['created_at'].present?
      end

      def updated_at
        attributes['updated_at'].to_f if attributes['updated_at'].present?
      end
    end
  end
end
