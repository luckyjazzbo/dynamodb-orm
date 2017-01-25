module Mes
  module Dynamo
    class Model
      module Execution
        extend ActiveSupport::Concern

        NUM_RETRIES = 15

        private

        def cls
          self.class
        end

        class_methods do
          attr_accessor :sleep_on_retry

          def client
            @client ||= Connection.connect
          end

          def client_execute(method, opts)
            default_options = { table_name: table_name }
            final_options = default_options.merge(opts)
            logger.debug "Request: #{final_options.inspect}"

            execute do
              client.send method, final_options
            end
          end

          def execute(&block)
            tries ||= NUM_RETRIES
            instance_exec(&block)
          rescue ::Aws::DynamoDB::Errors::ServiceError => origin_error
            tries -= 1
            if tries == 0
              raise Mes::Dynamo::GenericError.mes_error_for(origin_error)
            else
              sleep((NUM_RETRIES - tries - 1) * 0.1) if sleep_on_retry
              retry
            end
          end
        end
      end
    end
  end
end
