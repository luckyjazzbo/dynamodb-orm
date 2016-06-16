require 'active_support/all'
require 'aws-sdk'

RACK_ENV = ENV.fetch('RACK_ENV', 'development') unless defined?(RACK_ENV)

require 'mes/dynamo/model/execution'
require 'mes/dynamo/model/attributes'
require 'mes/dynamo/model/lookup_methods'
require 'mes/dynamo/model/table_actions'
require 'mes/dynamo/model/crud_actions'
require 'mes/dynamo/model/callbacks'
require 'mes/dynamo/model'
require 'mes/dynamo/errors'
require 'mes/dynamo/timestamps'
require 'mes/dynamo/table_index'
require 'mes/dynamo/table_field'
require 'mes/dynamo/table_creator'

require 'helpers/partition_helper'

require 'models/mes/original_resource'
require 'models/mes/transformation_step'
require 'models/mes/transformed_resource'

require 'mes/dynamo/version'

module Mes
  module Dynamo
    autoload :Connection, 'mes/dynamo/connection'
    autoload :Chain,      'mes/dynamo/chain'

    ROOT = File.expand_path('../../../', __FILE__)
    MODELS = Dir[File.join(ROOT, 'app/models/mes/*.rb')].map do |file|
      model_name = File.basename(file, '.rb').classify
      "Mes::#{model_name}".constantize
    end.freeze

    cattr_writer :logger

    def self.logger
      @logger ||= Logger.new('/dev/null')
    end
  end
end
