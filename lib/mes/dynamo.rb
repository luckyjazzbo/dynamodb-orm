require 'active_support/core_ext/object'
require 'active_support/core_ext/string'
require 'active_support/core_ext/module'
require 'active_support/core_ext/hash'
require 'active_support/concern'
require 'active_support/securerandom_base58'
require 'active_model'
require 'aws-sdk'
require 'faraday'
require 'mes-ruby-common'

RACK_ENV = ENV.fetch('RACK_ENV', 'development') unless defined?(RACK_ENV)

require 'mes/dynamo/model/execution'
require 'mes/dynamo/model/attributes'
require 'mes/dynamo/model/lookup_methods'
require 'mes/dynamo/model/table_actions'
require 'mes/dynamo/model/relations'
require 'mes/dynamo/model/crud_actions'
require 'mes/dynamo/model/callbacks'
require 'mes/dynamo/soft_deletion'
require 'mes/dynamo/model'
require 'mes/dynamo/errors'
require 'mes/dynamo/timestamps'
require 'mes/dynamo/table_index'
require 'mes/dynamo/table_field'
require 'mes/dynamo/table_describer'
require 'mes/dynamo/table_creator'
require 'mes/dynamo/table_updater'
require 'mes/dynamo/version'

require 'helpers/period_helper'
require 'helpers/content_id_service_client'
require 'validators/email_validator'
require 'models/mes/concerns/content_id'
require 'yaml'

module Mes
  module Dynamo
    autoload :Connection, 'mes/dynamo/connection'
    autoload :Chain,      'mes/dynamo/chain'

    ROOT = File.expand_path('../../../', __FILE__)
    PROVISIONING_CONFIG = YAML.load_file(
      File.join(Dynamo::ROOT, 'config/provisioning.yml')
    ).fetch(RACK_ENV)

    cattr_writer :logger

    def self.models
      @models ||= Dir[File.join(ROOT, 'app/models/mes/*.rb')].map do |file|
        model_class = File.basename(file, '.rb').classify
        "Mes::#{model_class}".constantize
      end
    end

    def self.logger
      @logger ||= Logger.new('/dev/null')
    end
  end

  Dir[File.join(Dynamo::ROOT, 'app/models/mes/*.rb')].map do |file|
    model_class = File.basename(file, '.rb').classify
    autoload model_class, file
  end
end
