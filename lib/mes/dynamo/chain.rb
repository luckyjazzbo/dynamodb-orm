module Mes
  module Dynamo
    class Chain
      include Enumerable

      def initialize(model_class, opts = {})
        @model_class = model_class
        @is_scan = opts[:scan]
        @where_filters = []
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
          chain.custom_options.deep_merge!(opts)
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

      def filter(expression, values = {})
        if expression.is_a?(Hash)
          values = expression
          expression = build_expression_from_values(expression)
        end

        dup.tap do |chain|
          chain.filters << { expression: expression, values: values }
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

      attr_accessor :model_class,
                    :where_filters,
                    :index_name,
                    :direction,
                    :limit_of_results,
                    :select_fields,
                    :custom_options,
                    :filters

      def update_filter(expression, values)
        where_filters << {
          expression: expression,
          values: values
        }
      end

      def build_expression_from_values(values)
        values.map { |key, _| "#{key} = :#{key}" }.join(' AND ')
      end

      def filter_expression
        where_filters.map { |filter| filter[:expression] }.join(' AND ')
      end

      def expression_attribute_values
        where_filters.map { |filter| format_values(filter[:values]) }
               .reduce({}, :merge)
      end

      def format_values(values)
        values.each_with_object({}) do |(key, value), hash|
          hash[":#{key}"] = value
        end
      end

      def where_filters_options
        opts = query_only_options.deep_merge(filters_options)
        opts[:index_name] = index_name  if index_name.present?
        opts[:limit] = limit_of_results if limit_of_results.present?

        if select_fields.is_a?(Array)
          opts[:attributes_to_get] = select_fields
          opts[:select] = 'SPECIFIC_ATTRIBUTES'
        else
          opts[:select] = select_fields || 'ALL_ATTRIBUTES'
        end

        opts.deep_merge(custom_options)
      end

      def filters_options
        used_filters = scan? ? filters + where_filters : filters
        return {} if used_filters.empty?
        {
          filter_expression: used_filters
            .map { |f| f[:expression] }.join(' AND '),
          expression_attribute_values: used_filters
            .map { |f| format_values(f[:values]) }.reduce({}, :merge)
        }
      end

      def query_only_options
        return {} if scan?
        {
          key_condition_expression: filter_expression,
          expression_attribute_values: expression_attribute_values,
          scan_index_forward: (direction == 'asc')
        }
      end

      def execute(extra_options = {})
        options = where_filters_options.merge(extra_options)
        if scan?
          model_class.client_execute(:scan, options)
        else
          model_class.client_execute(:query, options)
        end
      end

      def logger
        Mes::Dynamo.logger
      end

      def reverse_order
        self.direction = (direction == 'asc') ? 'desc' : 'asc'
      end
    end
  end
end
