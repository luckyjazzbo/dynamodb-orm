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

      def initialize(model_class, opts = {})
        @model_class = model_class
        @is_scan = opts[:scan]
        @filters = []
        @direction = 'asc'
        @custom_options = {}
      end

      def empty?
        count == 0
      end

      def scan?
        @is_scan
      end

      def raw(opts)
        dup.tap do |chain|
          chain.custom_options.merge!(opts)
        end
      end

      def project(select_fields)
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

      def order(direction)
        valid_directions = %(desc asc).freeze
        normalized_direction = direction.to_s.downcase
        raise InvalidQuery, 'Ordering is not supported in scan mode' if scan?
        raise InvalidOrder, 'Order must be one of "desc" or "asc"'   unless valid_directions.include?(normalized_direction)

        dup.tap do |chain|
          chain.direction = normalized_direction
        end
      end

      def first
        dup.tap do |chain|
          chain.limit_of_results = 1
        end.to_a.first
      end

      def last
        raise InvalidQuery, 'Ordering is not supported in scan mode' if scan?

        dup.tap do |chain|
          chain.limit_of_results = 1
          chain.reverse_order
        end.to_a.first
      end

      def each
        extra_options = {}
        total = 0
        loop do
          response = execute(extra_options)
          total += response.count

          response.items.each do |item_attrs|
            yield model_class.new(item_attrs)
          end

          break if limit_of_results.present? && total >= limit_of_results
          break if response.last_evaluated_key.nil?
          extra_options[:exclusive_start_key] = response.last_evaluated_key
          logger.debug "Reached 1Mb limit on #{response.last_evaluated_key} row, continuing"
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
        values.map { |key, _| "#{key} = :#{key}" }.join(' AND ')
      end

      def filter_expression
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

      def filter_options
        opts = scan? ? scan_only_options : query_only_options
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

      def query_only_options
        {
          key_condition_expression: filter_expression,
          expression_attribute_values: expression_attribute_values,
          scan_index_forward: (direction == 'asc')
        }
      end

      def scan_only_options
        if filter_expression.present?
          {
            filter_expression: filter_expression,
            expression_attribute_values: expression_attribute_values
          }
        else
          {}
        end
      end

      def execute(extra_options = {})
        options = filter_options.merge(extra_options)
        if scan?
          model_class.client_execute(:scan, options)
        else
          model_class.client_execute(:query, options)
        end
      end

      def logger
        ::Mes::Dynamo.logger
      end

      def reverse_order
        self.direction = (direction == 'asc') ? 'desc' : 'asc'
      end
    end
  end
end
