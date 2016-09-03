require 'spec_helper'

RSpec.describe Mes::Dynamo::TableCreator do
  before do
    define_provisioning_for(model_class)
    drop_table(model_class.table_name)
  end

  subject do
    described_class.new(model_class).create
    wait_till_table_create(model_class.table_name)
  end

  context 'when no fields are defined' do
    class ModelWithoutFieldsAndIndices < Mes::Dynamo::Model
      table primary_key: 'test_id'
    end
    let(:model_class) { ModelWithoutFieldsAndIndices }

    it 'creates corresponding table' do
      subject

      expect(
        describe_table(model_class.table_name)
          .slice(:table_name, :table_status, :attribute_definitions, :key_schema)
      ).to eq(
        table_name: model_class.table_name,
        table_status: 'ACTIVE',
        attribute_definitions: [{ attribute_name: 'test_id', attribute_type: 'S' }],
        key_schema: [{ attribute_name: 'test_id', key_type: 'HASH' }]
      )
    end
  end

  context 'when some fields are defined without indices' do
    class ModelWithFieldsWithoutIndices < Mes::Dynamo::Model
      table primary_key: 'test_id'
      field :title, type: :string
    end
    let(:model_class) { ModelWithFieldsWithoutIndices }

    it 'creates corresponding table' do
      subject

      expect(
        describe_table(model_class.table_name)
          .slice(:table_name, :table_status, :attribute_definitions, :key_schema)
      ).to eq(
        table_name: model_class.table_name,
        table_status: 'ACTIVE',
        attribute_definitions: [
          { attribute_name: 'test_id', attribute_type: 'S' }
        ],
        key_schema: [{ attribute_name: 'test_id', key_type: 'HASH' }]
      )
    end
  end

  context 'when some fields are defined with indices' do
    class ModelWithFieldsAndIndices < Mes::Dynamo::Model
      table primary_key: 'test_id'
      field :title, type: :string
      table_index :title
    end
    let(:model_class) { ModelWithFieldsAndIndices }

    it 'creates corresponding table' do
      subject

      expect(
        describe_table(model_class.table_name)
          .slice(:table_name, :table_status, :attribute_definitions, :key_schema)
      ).to eq(
        table_name: model_class.table_name,
        table_status: 'ACTIVE',
        attribute_definitions: [
          { attribute_name: 'test_id', attribute_type: 'S' },
          { attribute_name: 'title', attribute_type: 'S' }
        ],
        key_schema: [{ attribute_name: 'test_id', key_type: 'HASH' }]
      )

      expect(
        describe_table(model_class.table_name)[:global_secondary_indexes]
          .map { |index| index.slice(:index_name, :key_schema, :projection) }
      ).to eq([{
        index_name: 'title_index',
        key_schema: [{ attribute_name: 'title', key_type: 'HASH' }],
        projection: { projection_type: 'ALL' }
      }])
    end
  end
end
