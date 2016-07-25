module Mes
  module Dynamo
    class Model
      module Relations
        def belongs_to(name, settings = {})
          field_name = relation_field(name, settings)
          field(field_name, settings)
          define_relation_accessors(name, settings)
        end

        private

        def define_relation_accessors(name, settings)
          field_name = relation_field(name, settings)
          class_name = relation_class_name(name, settings)

          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{name}
              @#{name} ||= if #{field_name}.present?
                             #{class_name}.find(#{field_name})
                           end
            end

            def #{name}=(obj)
              if obj.nil?
                @#{name} = nil
                self.#{field_name} = nil
              elsif !obj.is_a?(#{class_name})
                raise ArgumentError, "Invalid object type \#{obj.class.name} for relation #{name}"
              else
                @#{name} = obj
                self.#{field_name} = obj.id
              end
            end
          RUBY
        end

        def relation_field(name, settings)
          settings[:foreign_key] || "#{name}_id"
        end

        def relation_class_name(name, settings)
          settings[:class_name] || name.to_s.classify
        end
      end
    end
  end
end
