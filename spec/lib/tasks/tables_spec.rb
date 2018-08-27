require 'spec_helper'

RSpec.describe 'tables.rake' do
  let(:rake) { Rake::Application.new }

  before do
    Rake.application = rake
    Dir[File.join(DynamodbOrm::ROOT, 'lib/tasks/**/*.rake')].each { |f| load(f) }
  end

  describe 'dynamodb_orm:create_tables' do
    subject { rake['dynamodb_orm:create_tables'] }

    before do
      DynamodbOrm.models.each { |model_class| drop_table(model_class.table_name) }
    end

    it 'creates tables' do
      subject.invoke
      DynamodbOrm.models.each do |model_class|
        expect(table_exists?(model_class.table_name)).to be_truthy
      end
    end
  end

  describe 'dynamodb_orm:drop_tables' do
    subject { rake['dynamodb_orm:drop_tables'] }

    before do
      DynamodbOrm.models.each do |model_class|
        model_class.create_table! unless table_exists?(model_class.table_name)
      end
    end

    it 'drops tables' do
      subject.invoke
      DynamodbOrm.models.each do |model_class|
        expect(table_exists?(model_class.table_name)).to be_falsey
      end
    end
  end
end
