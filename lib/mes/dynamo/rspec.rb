require File.join(Mes::Dynamo::ROOT, 'spec/support/mes/dynamo/dynamo')
require File.join(Mes::Dynamo::ROOT, 'spec/support/mes/dynamo/with_dynamodb_table')
require File.join(Mes::Dynamo::ROOT, 'spec/support/mes/dynamo/with_mes_tables')

require 'factory_girl'
Dir[File.join(Mes::Dynamo::ROOT, 'spec/factories/**/*.rb')].each { |file| require(file) }
