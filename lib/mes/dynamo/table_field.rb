module Mes
  module Dynamo
    class TableField
      TYPES = {
        string: 'S',
        number: 'N'
      }.freeze

      attr_reader :name, :type

      def initialize(field_name, settings)
        @name = field_name.to_sym
        @type = settings[:type].to_sym if settings.key?(:type)

        validate_type!
      end

      def dynamodb_type
        TYPES[type] if type.present?
      end

      private

      def validate_type!
        raise InvalidFieldType, "Unknown field type '#{type}'" if type && !TYPES.key?(type)
      end
    end
  end
end
