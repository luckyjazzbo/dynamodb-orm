RSpec.shared_context 'with mes tables' do
  before(:all) do
    Mes::Dynamo.models.each do |model_class|
      drop_table(model_class.table_name)
      Mes::Dynamo::TableCreator.new(model_class).create
    end
  end

  after(:all) do
    Mes::Dynamo.models.each do |model_class|
      drop_table(model_class.table_name)
    end
  end

  before(:each) do
    Mes::Dynamo.models.each(&:truncate!)
  end
end
