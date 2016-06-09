module LteCore
  module DynamoDB
    GenericError        = Class.new(StandardError)
    AttributeNotDefined = Class.new(GenericError)
    RecordNotFound      = Class.new(GenericError)
    ValidationError     = Class.new(GenericError)
    TableDoesNotExist   = Class.new(GenericError)
    InvalidQuery        = Class.new(GenericError)
  end
end
