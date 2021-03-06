RACK_ENV = 'test'.freeze unless defined?(RACK_ENV)

require 'bundler/setup'
Bundler.setup

require 'dotenv'
Dotenv.load(".env.#{RACK_ENV}")

require 'rake'
require 'dynamodb-orm'
require 'webmock/rspec'
require 'timecop'

WebMock.disable_net_connect!(allow: ENV['DYNAMODB_ENDPOINT'])

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.order = :random

  config.before(:all) do
    drop_all_tables
  end
end
