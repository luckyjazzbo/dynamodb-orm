module Mes
  module Dynamo
    class TableField
      TYPES = {
        string:     'S',
        string_set: 'SS',
        number:     'N',
        number_set: 'NS',
        binary:     'B',
        binary_set: 'BS',
        boolean:    'BOOL',
        list:       'L',
        map:        'M',
        null:       'NULL'
      }.freeze

      attr_reader :name, :type

      def initialize(field_name, settings)
        @name = field_name.to_sym
        @default = settings[:default]
        if settings.key?(:type)
          @type = settings[:type].to_sym
          validate_type!
        end
      end

      def default?
        !@default.nil?
      end

      def default
        if @default.respond_to?(:call)
          @default.call
        else
          @default
        end
      end

      def dynamodb_type
        TYPES[type]
      end

      def boolean?
        type == :boolean
      end

      private

      def validate_type!
        raise InvalidFieldType, "Unknown field type '#{type}'" if type && !TYPES.key?(type)
      end
    end
  end
end
