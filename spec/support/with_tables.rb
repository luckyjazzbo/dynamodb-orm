RSpec.shared_context 'with mes tables' do
  before(:all) do
    DynamodbOrm.models.each do |model_class|
      drop_table(model_class.table_name)
      DynamodbOrm::TableCreator.new(model_class).create
    end
  end

  after(:all) do
    DynamodbOrm.models.each do |model_class|
      drop_table(model_class.table_name)
    end
  end

  before(:each) do
    DynamodbOrm.models.each(&:truncate!)
  end
end
