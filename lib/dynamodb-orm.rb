require 'active_support/core_ext/object'
require 'active_support/core_ext/string'
require 'active_support/core_ext/module'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/securerandom'
require 'active_support/concern'
require 'active_model'
require 'aws-sdk'
require 'faraday'
require 'yaml'

RACK_ENV = ENV.fetch('RACK_ENV', 'development') unless defined?(RACK_ENV)

require 'dynamodb-orm/model/execution'
require 'dynamodb-orm/model/attributes'
require 'dynamodb-orm/model/lookup_methods'
require 'dynamodb-orm/model/table_actions'
require 'dynamodb-orm/model/relations'
require 'dynamodb-orm/model/crud_actions'
require 'dynamodb-orm/model/callbacks'
require 'dynamodb-orm/soft_deletion'
require 'dynamodb-orm/model'
require 'dynamodb-orm/errors'
require 'dynamodb-orm/timestamps'
require 'dynamodb-orm/table_index'
require 'dynamodb-orm/table_field'
require 'dynamodb-orm/table_describer'
require 'dynamodb-orm/table_creator'
require 'dynamodb-orm/table_updater'
require 'dynamodb-orm/version'


module DynamodbOrm
  autoload :Connection, 'dynamodb-orm/connection'
  autoload :Chain,      'dynamodb-orm/chain'

  ROOT = File.expand_path('../../', __FILE__)
  PROVISIONING_PATH = 'config/provisioning.yml'.freeze

  cattr_writer :logger

  class << self
    def models
      @models ||= begin
        classes = models_folders.map do |folder|
          Dir["#{folder}/**/*.rb"].map do |file|
            constantize_path(folder, file)
          end
        end
        classes
          .flatten
          .compact
          .select { |clazz| clazz < DynamodbOrm::Model }
      end
    end

    def constantize_path(folder, file)
      model_name = File.basename(file, '.rb')
      model_module = File.dirname(file).gsub(folder, '')[1..-1]
      model_name = "#{model_module}/#{model_name}" if model_module.present?
      model_name.classify.safe_constantize
    end

    def models_folders
      base_models_folders + app_models_folders
    end

    def base_models_folders
      [File.join(ROOT, 'app/models')]
    end

    def app_models_folders
      return [] unless defined?(App) && App.respond_to?(:root)
      [File.join(App.root, 'app/models')]
    end

    def logger
      @logger ||= Logger.new('/dev/null')
    end

    def provisioning_config
      @provisioning_config ||=
        if defined?(App) && App.respond_to?(:root) && File.exist?(File.join(App.root, PROVISIONING_PATH))
          YAML.load_file(File.join(App.root, PROVISIONING_PATH)).fetch(RACK_ENV)
        else
          {}
        end
    end
  end
end

require_relative 'dynamodb-orm/install_rake_tasks'
