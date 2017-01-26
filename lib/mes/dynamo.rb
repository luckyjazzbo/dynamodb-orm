require 'active_support/core_ext/object'
require 'active_support/core_ext/string'
require 'active_support/core_ext/module'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/securerandom'
require 'active_support/concern'
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
    PROVISIONING_PATH = 'config/provisioning.yml'.freeze

    cattr_writer :logger

    class << self
      def models
        @models ||= Dir[File.join(ROOT, 'app/models/mes/*.rb')].map do |file|
          model_class = File.basename(file, '.rb').classify
          "Mes::#{model_class}".constantize
        end
      end

      def logger
        @logger ||= Mes::Common::LoggerWithPrefix.new(
          Mes::Common::LoggerUtils.current_logger, '[mes-dynamo]'
        )
      end

      def provisioning_config
        @provisioning_config ||= dynamo_config.deep_merge(app_config)
      end

      def dynamo_config
        YAML.load_file(File.join(ROOT, PROVISIONING_PATH)).fetch(RACK_ENV)
      end

      def app_config
        return {} unless defined?(App) &&
                         App.respond_to?(:root) &&
                         File.exist?(File.join(App.root, PROVISIONING_PATH))
        YAML.load_file(File.join(App.root, PROVISIONING_PATH)).fetch(RACK_ENV)
      end
    end
  end

  Dir[File.join(Dynamo::ROOT, 'app/models/mes/*.rb')].map do |file|
    model_class = File.basename(file, '.rb').classify
    autoload model_class, file
  end
end
