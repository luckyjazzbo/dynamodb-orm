module Mes
  module Dynamo
    class Model
      module Attributes
        attr_reader :attributes

        def init_attributes(attrs)
          @attributes = {}.with_indifferent_access
          assign_attributes(attrs.stringify_keys)

          cls.fields.each do |field_name, field|
            next if @attributes.key?(field_name)
            @attributes[field_name] = field.default if field.default?
          end
        end

        def primary_key
          read_attribute(cls.primary_key)
        end

        def read_attribute(name)
          attributes[name]
        end

        def write_attribute(name, value)
          attributes[name] = field(name).cast_type(value) if attribute?(name)
        end

        def field(name)
          cls.fields[name]
        end

        def attribute?(name)
          cls.fields && cls.fields.key?(name)
        end

        def assign_attributes(attributes)
          attributes.each do |name, value|
            write_attribute(name, value)
          end
        end

        def <=>(other)
          return -1 if primary_key.nil? || other.try(:primary_key).nil? || !other.is_a?(self.class)
          primary_key <=> other.primary_key
        end

        def method_missing(name, *args)
          if attribute?(name)
            read_attribute(name)
          elsif attribute_setter?(name)
            write_attribute normalize_name(name), args[0]
          elsif boolean_reader?(name)
            read_attribute normalize_name(name)
          else
            super
          end
        end

        def respond_to?(method, include_private = false)
          attribute?(method) ||
            attribute_setter?(method) ||
            boolean_reader?(method) ||
            super
        end

        private

        def attribute_setter?(name)
          name = name.to_s
          name[-1] == '=' && attribute?(name[0..-2])
        end

        def boolean_reader?(name)
          name = name.to_s
          name[-1] == '?' && boolean_attribute?(name[0..-2])
        end

        def boolean_attribute?(name)
          attribute?(name) && cls.fields[name].boolean?
        end

        def normalize_name(name)
          if attribute_setter?(name) || boolean_reader?(name)
            name.to_s[0..-2]
          else
            name.to_s
          end
        end
      end
    end
  end
end
