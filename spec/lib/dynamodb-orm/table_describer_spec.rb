require 'spec_helper'

RSpec.describe DynamodbOrm::TableDescriber do
  class ModelWithoutFieldsAndIndices < DynamodbOrm::Model
    table primary_key: 'test_id'
  end
  let(:model_class) { ModelWithoutFieldsAndIndices }
  subject { described_class.new(model_class).state }

  context 'when table do not exist' do
    before do
      define_provisioning_for(model_class)
      drop_table(model_class.table_name)
    end

    it { is_expected.to be_nil}
  end

  context 'when no fields are defined' do

    before do
      define_provisioning_for(model_class)
      drop_table(model_class.table_name)
      model_class.create_table!
      wait_till_table_create(model_class.table_name)
    end

    it 'loads exact descriptions from Dynamo' do
      expect(subject).to eq(
        model_class.table_settings
      )
    end
  end

  context 'when some fields are defined without indices' do
    class ModelWithFieldsWithoutIndices < DynamodbOrm::Model
      table primary_key: 'test_id'
      field :title, type: :string
    end
    let(:model_class) { ModelWithFieldsWithoutIndices}


    before do
      define_provisioning_for(model_class)
      drop_table(model_class.table_name)
      model_class.create_table!
      wait_till_table_create(model_class.table_name)
    end

    it 'loads exact descriptions from Dynamo' do
      expect(subject).to eq(
        model_class.table_settings
      )
    end
  end

  context 'when some fields are defined without indices' do
    class ModelWithFieldsAndIndices < DynamodbOrm::Model
      table primary_key: 'test_id'
      field :title, type: :string
      table_index :title
    end
    let(:model_class) { ModelWithoutFieldsAndIndices }


    before do
      define_provisioning_for(model_class)
      drop_table(model_class.table_name)
      model_class.create_table!
      wait_till_table_create(model_class.table_name)
    end

    it 'loads exact descriptions from Dynamo' do
      expect(subject).to eq(
        model_class.table_settings
      )
    end
  end
end
