require File.join(Mes::Dynamo::ROOT, 'spec/support/dynamo')
require File.join(Mes::Dynamo::ROOT, 'spec/support/with_dynamodb_table')
require File.join(Mes::Dynamo::ROOT, 'spec/support/with_mes_tables')

Dir[File.join(Mes::Dynamo::ROOT, 'spec/factories/**/*.rb')].each { |file| require(file) }
