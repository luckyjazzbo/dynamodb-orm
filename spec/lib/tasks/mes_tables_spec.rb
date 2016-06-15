require 'spec_helper'

RSpec.describe 'mes_tables.rake' do
  let(:rake) { Rake::Application.new }
  let(:daemonizer) { double('daemonizer') }

  before do
    Rake.application = rake
    Dir[File.join(Mes::Dynamo::ROOT, 'lib/tasks/**/*.rake')].each { |f| load(f) }
  end

  describe 'mes_tables:create_all' do
    subject { rake['mes_tables:create_all'] }

    before do
      ::Mes::Dynamo::MODELS.each { |model_class| drop_table(model_class.table_name) }
    end

    it 'creates tables' do
      subject.invoke
      ::Mes::Dynamo::MODELS.each do |model_class|
        expect(table_exists?(model_class.table_name)).to be_truthy
      end
    end
  end

  describe 'mes_tables:drop_all' do
    subject { rake['mes_tables:drop_all'] }

    before do
      ::Mes::Dynamo::MODELS.each do |model_class|
        model_class.create unless table_exists?(model_class.table_name)
      end
    end

    it 'drops tables' do
      subject.invoke
      ::Mes::Dynamo::MODELS.each do |model_class|
        expect(table_exists?(model_class.table_name)).to be_falsey
      end
    end
  end
end
