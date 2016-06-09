module LteCore
  module DynamoDB
    module Connection
      def setup(options)
        @options = options
      end

      def default_options
        {
          region: 'eu-west-1'
        }
      end

      def connect
        options = @options || {}
        opts = default_options.merge(options)
        ::Aws::DynamoDB::Client.new(opts)
      end

      module_function :setup, :connect, :default_options
    end
  end
end
