ENV['DYNAMODB_ENDPOINT'] = 'http://dynamodb:8000'
RACK_ENV = 'test'.freeze unless defined?(RACK_ENV)

require 'bundler/setup'
Bundler.setup

require 'mes/dynamo'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow: ENV['DYNAMODB_ENDPOINT'])

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.order = :random
end
