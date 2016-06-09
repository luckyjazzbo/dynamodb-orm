require 'active_support/all'
require 'aws-sdk'

require "lte_core/dynamodb/version"
require 'lte_core/dynamodb/errors'

module LteCore
  module DynamoDB
    autoload :Connection, 'lte_core/dynamodb/connection'
    autoload :Model,      'lte_core/dynamodb/model'
    autoload :Chain,      'lte_core/dynamodb/chain'
    autoload :Callbacks,  'lte_core/dynamodb/callbacks'
    autoload :Timestamps, 'lte_core/dynamodb/timestamps'
  end
end
