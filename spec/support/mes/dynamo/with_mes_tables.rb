RSpec.shared_context 'with mes tables' do
  before(:all) do
    ::Mes::Dynamo::MODELS.each do |model_class|
      Mes::Dynamo::TableCreator.new(model_class).create_table!
    end
  end

  after(:all) do
    ::Mes::Dynamo::MODELS.each do |model_class|
      drop_table(model_class.table_name)
    end
  end

  before(:each) do
    ::Mes::Dynamo::MODELS.each(&:truncate!)
  end
end
