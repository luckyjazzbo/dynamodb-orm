require 'spec_helper'

RSpec.describe Mes::Dynamo::TableCreator do
  context 'when no fields are defined' do
    class ModelWithoutFieldsAndIndices < Mes::Dynamo::Model
      table primary_key: 'test_id'
    end

    before do
      define_provisioning_for(ModelWithoutFieldsAndIndices)
      drop_table(ModelWithoutFieldsAndIndices.table_name)
    end

    it 'creates corresponding table' do
      described_class.new(ModelWithoutFieldsAndIndices).create
      wait_till_table_create(ModelWithoutFieldsAndIndices.table_name)

      expect(
        describe_table(ModelWithoutFieldsAndIndices.table_name)
          .slice(:table_name, :table_status, :attribute_definitions, :key_schema)
      ).to eq(
        table_name: ModelWithoutFieldsAndIndices.table_name,
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

    before do
      define_provisioning_for(ModelWithFieldsWithoutIndices)
      drop_table(ModelWithFieldsWithoutIndices.table_name)
    end

    it 'creates corresponding table' do
      described_class.new(ModelWithFieldsWithoutIndices).create
      wait_till_table_create(ModelWithFieldsWithoutIndices.table_name)

      expect(
        describe_table(ModelWithFieldsWithoutIndices.table_name)
          .slice(:table_name, :table_status, :attribute_definitions, :key_schema)
      ).to eq(
        table_name: ModelWithFieldsWithoutIndices.table_name,
        table_status: 'ACTIVE',
        attribute_definitions: [
          { attribute_name: 'test_id', attribute_type: 'S' }
        ],
        key_schema: [{ attribute_name: 'test_id', key_type: 'HASH' }]
      )
    end
  end

  context 'when some fields are defined without indices' do
    class ModelWithFieldsAndIndices < Mes::Dynamo::Model
      table primary_key: 'test_id'
      field :title, type: :string
      table_index :title
    end

    before do
      define_provisioning_for(ModelWithFieldsAndIndices)
      drop_table(ModelWithFieldsAndIndices.table_name)
    end

    it 'creates corresponding table' do
      described_class.new(ModelWithFieldsAndIndices).create
      wait_till_table_create(ModelWithFieldsAndIndices.table_name)

      expect(
        describe_table(ModelWithFieldsAndIndices.table_name)
          .slice(:table_name, :table_status, :attribute_definitions, :key_schema)
      ).to eq(
        table_name: ModelWithFieldsAndIndices.table_name,
        table_status: 'ACTIVE',
        attribute_definitions: [
          { attribute_name: 'test_id', attribute_type: 'S' },
          { attribute_name: 'title', attribute_type: 'S' }
        ],
        key_schema: [{ attribute_name: 'test_id', key_type: 'HASH' }]
      )

      expect(
        describe_table(ModelWithFieldsAndIndices.table_name)[:global_secondary_indexes]
          .map { |index| index.slice(:index_name, :key_schema, :projection) }
      ).to eq([{
        index_name: 'title_index',
        key_schema: [{ attribute_name: 'title', key_type: 'HASH' }],
        projection: { projection_type: 'ALL' }
      }])
    end
  end
end
