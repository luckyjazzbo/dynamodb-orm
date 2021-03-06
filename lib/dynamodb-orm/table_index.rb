module DynamodbOrm
  class TableIndex
    attr_reader :name, :hash, :range

    def initialize(hash_field, settings)
      @hash = hash_field.to_sym
      @range = cleanup_range(settings[:range])
      @name = settings[:name] || autogenerate_table_name
    end

    def all_fields
      [hash] + range
    end

    def has_key?(key)
      all_fields.include? key
    end

    private

    def cleanup_range(range)
      range ||= []
      range.is_a?(Array) ? range.map(&:to_sym) : [range.to_sym]
    end

    def autogenerate_table_name
      all_fields.map(&:to_s).join('_') + '_index'
    end
  end
end
