module Mes
  module Dynamo
    class GenericError < StandardError
      def self.mes_error_for(origin_error = nil)
        error_class = mes_error_class_for(origin_error)
        return origin_error unless error_class

        error_class.new(origin_error.message).tap do |error|
          error.set_backtrace(origin_error.backtrace)
        end
      end

      def self.mes_error_class_for(origin_error)
        case origin_error
        when ::Aws::DynamoDB::Errors::ResourceNotFoundException
          TableDoesNotExist
        when ::Aws::DynamoDB::Errors::ValidationException
          if origin_error.message.include? 'ExpressionAttributeValues'
            InvalidQuery
          else
            InvalidRecord
          end
        end
      end
    end

    AttributeNotDefined    = Class.new(GenericError)
    RecordNotFound         = Class.new(GenericError)
    TableDoesNotExist      = Class.new(GenericError)
    InvalidOrder           = Class.new(GenericError)
    InvalidQuery           = Class.new(GenericError)
    InvalidFieldType       = Class.new(GenericError)
    InvalidRecord          = Class.new(GenericError)
    InvalidUpdateOperation = Class.new(GenericError)

    # INFO: DEPRECATED, use InvalidRecord instead
    ValidationError        = Class.new(InvalidRecord)
  end
end
