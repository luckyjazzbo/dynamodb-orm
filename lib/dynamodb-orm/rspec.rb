require File.join(DynamodbOrm::ROOT, 'spec/support/dynamodb-orm/dynamo')
require File.join(DynamodbOrm::ROOT, 'spec/support/dynamodb-orm/with_dynamodb_table')
require File.join(DynamodbOrm::ROOT, 'spec/support/dynamodb-orm/with_mes_tables')

require 'factory_girl'
Dir[File.join(DynamodbOrm::ROOT, 'spec/factories/**/*.rb')].each { |file| require(file) }
