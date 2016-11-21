require 'spec_helper'

RSpec.describe 'mes_tables.rake' do
  let(:rake) { Rake::Application.new }

  before do
    Rake.application = rake
    Dir[File.join(Mes::Dynamo::ROOT, 'lib/tasks/**/*.rake')].each { |f| load(f) }
  end

  describe 'mes:dynamo:create_tables' do
    subject { rake['mes:dynamo:create_tables'] }

    before do
      Mes::Dynamo.models.each { |model_class| drop_table(model_class.table_name) }
    end

    it 'creates tables' do
      subject.invoke
      Mes::Dynamo.models.each do |model_class|
        expect(table_exists?(model_class.table_name)).to be_truthy
      end
    end
  end

  describe 'mes:dynamo:drop_tables' do
    subject { rake['mes:dynamo:drop_tables'] }

    before do
      Mes::Dynamo.models.each do |model_class|
        model_class.create_table! unless table_exists?(model_class.table_name)
      end
    end

    it 'drops tables' do
      subject.invoke
      Mes::Dynamo.models.each do |model_class|
        expect(table_exists?(model_class.table_name)).to be_falsey
      end
    end
  end
end
