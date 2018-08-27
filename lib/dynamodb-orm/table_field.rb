module DynamodbOrm
  class TableField
    TYPES = {
      string:     'S',
      string_set: 'SS',
      integer:    'N',
      float:      'N',
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
      return unless settings.key?(:type)
      @type = settings[:type].to_sym
      validate_type!
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

    def cast_type(value)
      case type
      when :float
        value.to_f
      when :integer
        value.to_i
      when :string
        value.to_s.empty? ? nil : value.to_s
      else
        deep_cast(value, BigDecimal, &:to_f)
        deep_cast(value, String) { |val| val.empty? ? nil : val }
      end
    end

    private

    def deep_cast(value, klass, &block)
      case value
      when Hash
        value.each { |key, val| value[key] = deep_cast(val, klass, &block) }
        value
      when Array
        value.map! { |val| deep_cast(val, klass, &block) }
      when klass
        yield value
      else value
      end
    end

    def validate_type!
      raise InvalidFieldType, "Unknown field type '#{type}'" if type && !TYPES.key?(type)
    end
  end
end
