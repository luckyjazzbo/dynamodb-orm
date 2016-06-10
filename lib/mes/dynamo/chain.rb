module Mes
  module Dynamo
    class Chain
      include Enumerable

      attr_accessor :model_class,
                    :filters,
                    :index_name,
                    :direction,
                    :limit_of_results,
                    :select_fields,
                    :custom_options

      def initialize(model_class)
        @model_class = model_class
        @filters = []
        @direction = 'asc'
        @custom_options = {}
      end

      def raw(opts)
        dup.tap do |chain|
          chain.custom_options.merge!(opts)
        end
      end

      def select(select_fields)
        dup.tap do |chain|
          chain.select_fields = select_fields
        end
      end

      def where(expression, values = {})
        if expression.is_a?(Hash)
          values = expression
          expression = build_expression_from_values(expression)
        end

        dup.tap do |chain|
          chain.update_filter(expression, values)
        end
      end

      def index(index_name)
        dup.tap do |chain|
          chain.index_name = index_name
        end
      end

      def limit(limit)
        dup.tap do |chain|
          chain.limit_of_results = limit
        end
      end

      def first
        dup.tap do |chain|
          chain.limit_of_results = 1
          chain.direction = 'asc'
        end.to_a.first
      end

      def last
        dup.tap do |chain|
          chain.limit_of_results = 1
          chain.direction = 'desc'
        end.to_a.first
      end

      def each
        execute.items.each do |item_attrs|
          yield model_class.new(item_attrs)
        end
      end

      protected

      def update_filter(expression, values)
        filters << {
          expression: expression,
          values: values
        }
      end

      def build_expression_from_values(values)
        values.map { |key, value| "#{key} = :#{key}" }.join(' AND ')
      end

      def key_condition_expression
        filters.map { |filter| filter[:expression] }.join(' AND ')
      end

      def expression_attribute_values
        values = {}
        filters.map do |filter|
          filter[:values].each do |key, value|
            values[":#{key}"] = value
          end
        end
        values
      end

      def query_options
        opts = {
          key_condition_expression:    key_condition_expression,
          expression_attribute_values: expression_attribute_values,
          scan_index_forward:          (direction == 'asc')
        }
        opts[:index_name] = index_name  if index_name.present?
        opts[:limit] = limit_of_results if limit_of_results.present?

        if select_fields.is_a?(Array)
          opts[:attributes_to_get] = select_fields
          opts[:select] = 'SPECIFIC_ATTRIBUTES'
        else
          opts[:select] = select_fields || 'ALL_ATTRIBUTES'
        end
        opts.merge(custom_options)
      end

      def execute
        if valid_query_options?
          model_class.client_execute(:query, query_options)
        else
          raise InvalidQuery, 'You must set an index and a filter'
        end
      end

      def valid_query_options?
        index_name.present? &&
          key_condition_expression.present? &&
          expression_attribute_values.present?
      end
    end
  end
end
