module Mes
  module Dynamo
    module Timestamps
      def self.included(base)
        base.field :created_at, type: :number
        base.field :updated_at, type: :number

        base.before_create do
          self.created_at = current_time
        end

        base.before_save do
          self.updated_at = current_time
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
