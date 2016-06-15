module Mes
  module Dynamo
    module Execution
      extend ActiveSupport::Concern

      private

      def cls
        self.class
      end

      class_methods do
        def client
          @client ||= Connection.connect
        end

        def client_execute(method, opts)
          default_options = { table_name: table_name }
          final_options = default_options.merge(opts)
          ::Mes::Dynamo.logger.debug "Request: #{final_options.inspect}"

          execute do
            client.send method, final_options
          end
        end

        def execute(&block)
          instance_exec(&block)
        rescue Aws::DynamoDB::Errors::ServiceError => origin_error
          raise Mes::Dynamo::GenericError.mes_error_for(origin_error)
        end
      end
    end
  end
end
