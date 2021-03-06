module DynamodbOrm
  class GenericError < StandardError
    RETRYABLE_AWS_ERRORS = [
      ::Aws::DynamoDB::Errors::ItemCollectionSizeLimitExceededException,
      ::Aws::DynamoDB::Errors::LimitExceededException,
      ::Aws::DynamoDB::Errors::ProvisionedThroughputExceededException,
      ::Aws::DynamoDB::Errors::ThrottlingException,
      ::Aws::DynamoDB::Errors::UnrecognizedClientException
    ].freeze

    def self.error_retryable?(origial_error)
      RETRYABLE_AWS_ERRORS.any? { |error_class| origial_error.is_a?(error_class) }
    end

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
end
