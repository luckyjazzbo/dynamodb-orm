require 'active_support/all'
require 'aws-sdk'

RACK_ENV = ENV.fetch('RACK_ENV', 'development') unless defined?(RACK_ENV)

require 'mes/dynamo/model'
require 'mes/dynamo/timestamps'
require 'mes/dynamo/callbacks'

# Models
require 'models/mes/original_resource'
require 'models/mes/transformation_step'
require 'models/mes/transformed_resource'

require "mes/dynamo/version"
require 'mes/dynamo/errors'

module Mes
  module Dynamo
    autoload :Connection, 'mes/dynamo/connection'
    autoload :Chain,      'mes/dynamo/chain'
  end
end
