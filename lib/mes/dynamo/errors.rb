module Mes
  module Dynamo
    class GenericError < StandardError
      def self.mes_error_for(origin_error = nil)
        error = mes_error_class_for(origin_error).new(origin_error.message)
        error.set_backtrace(origin_error.backtrace)
        error
      end

      def self.mes_error_class_for(origin_error)
        case origin_error
        when Aws::DynamoDB::Errors::ResourceNotFoundException
          TableDoesNotExist
        when Aws::DynamoDB::Errors::ValidationException
          if origin_error.message.include? 'ExpressionAttributeValues'
            InvalidQuery
          else
            ValidationError
          end
        end
      end
    end

    AttributeNotDefined = Class.new(GenericError)
    RecordNotFound      = Class.new(GenericError)
    ValidationError     = Class.new(GenericError)
    TableDoesNotExist   = Class.new(GenericError)
    InvalidOrder        = Class.new(GenericError)
    InvalidQuery        = Class.new(GenericError)
    InvalidFieldType    = Class.new(GenericError)
  end
end
