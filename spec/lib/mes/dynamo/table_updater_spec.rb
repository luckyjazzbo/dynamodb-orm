require 'spec_helper'

RSpec.describe Mes::Dynamo::TableUpdater do
  subject { described_class.new(model_class).update }
  class ModelWithoutFieldsAndIndicesForUpdate < Mes::Dynamo::Model
    table primary_key: 'test_id'
  end

  before do
    define_provisioning_for(model_class)
    drop_table(model_class.table_name)
  end

  context 'when nothing changed' do
    let(:model_class) { ModelWithoutFieldsAndIndicesForUpdate }

    before do
      create_table(
        model_class.table_name,
        attribute_definitions: [{ attribute_name: 'test_id', attribute_type: 'S' }],
        key_schema: [{ attribute_name: 'test_id', key_type: 'HASH' }],
        provisioned_throughput: { read_capacity_units: 1, write_capacity_units: 1 }
      )
      wait_till_table_create(model_class.table_name)
    end

    it 'does not perform update and returns false' do
      expect_any_instance_of(::Aws::DynamoDB::Client).not_to receive(:update_table)
      expect(subject).to eq false
    end
  end

  context 'when provisioned_throughput changed' do
    let(:model_class) { ModelWithoutFieldsAndIndicesForUpdate }

    before do
      create_table(
        model_class.table_name,
        attribute_definitions: [{ attribute_name: 'test_id', attribute_type: 'S' }],
        key_schema: [{ attribute_name: 'test_id', key_type: 'HASH' }],
        provisioned_throughput: { read_capacity_units: 2, write_capacity_units: 2 }
      )
      wait_till_table_create(model_class.table_name)
    end

    it 'updates table' do
      expect {
        subject
        wait_till_table_create(model_class.table_name)
      }
        .to change { model_class.describe_table }
        .to model_class.table_settings
    end
  end

  context 'when key_schema changed' do
    let(:model_class) { ModelWithoutFieldsAndIndicesForUpdate }

    before do
      create_table(
        model_class.table_name,
        attribute_definitions: [{ attribute_name: 'test2_id', attribute_type: 'S' }],
        key_schema: [{ attribute_name: 'test2_id', key_type: 'HASH' }],
        provisioned_throughput: { read_capacity_units: 2, write_capacity_units: 2 }
      )
      wait_till_table_create(model_class.table_name)
    end

    it 'raises exception' do
      expect { subject }.to raise_error Mes::Dynamo::InvalidUpdateOperation
    end
  end

  context 'with indexes' do
    context 'when valid operations are performed' do
      class ModelWithFieldsAndIndicesForUpdate < Mes::Dynamo::Model
        table primary_key: 'test_id'
        field :title, type: :string
        field :name, type: :string
        field :owner, type: :string
        field :author, type: :string

        table_index :title  # new index
        # table_index :name # removed index
        table_index :owner  # updated index (throughput)
        table_index :author # not changed index
      end
      let(:model_class) { ModelWithFieldsAndIndicesForUpdate }

      before do
        create_table(
          model_class.table_name,
          attribute_definitions: [
            { attribute_name: 'test_id', attribute_type: 'S' },
            { attribute_name: 'name', attribute_type: 'S' },
            { attribute_name: 'owner', attribute_type: 'S' },
            { attribute_name: 'author', attribute_type: 'S' }
          ],
          key_schema: [{ attribute_name: 'test_id', key_type: 'HASH' }],
          global_secondary_indexes: [
            {
              index_name: 'name_index',
              key_schema: [{ attribute_name: 'name', key_type: 'HASH' }],
              projection: { projection_type: 'ALL' },
              provisioned_throughput: { read_capacity_units: 1, write_capacity_units: 1 }
            },
            {
              index_name: 'owner_index',
              key_schema: [{ attribute_name: 'owner', key_type: 'HASH' }],
              projection: { projection_type: 'ALL' },
              provisioned_throughput: { read_capacity_units: 2, write_capacity_units: 2 }
            },
            {
              index_name: 'author_index',
              key_schema: [{ attribute_name: 'author', key_type: 'HASH' }],
              projection: { projection_type: 'ALL' },
              provisioned_throughput: { read_capacity_units: 1, write_capacity_units: 1 }
            }
          ]
        )
        wait_till_table_create(model_class.table_name)
      end

      it 'updates all the data' do
        subject
        wait_till_table_create(model_class.table_name)

        expect(model_class.describe_table).to eq model_class.table_settings
      end
    end

    context 'when key_schema changes' do
      class ModelWithUpdatableIndex < Mes::Dynamo::Model
        table primary_key: 'test_id'
        field :title, type: :string

        table_index :title, name: 'my_index' # index name did not change, but key_schema did
      end

      let(:model_class) { ModelWithUpdatableIndex }

      before do
        create_table(
          model_class.table_name,
          attribute_definitions: [
            { attribute_name: 'test_id', attribute_type: 'S' },
            { attribute_name: 'name', attribute_type: 'S' }
          ],
          key_schema: [{ attribute_name: 'test_id', key_type: 'HASH' }],
          global_secondary_indexes: [
            {
              index_name: 'my_index',
              key_schema: [{ attribute_name: 'name', key_type: 'HASH' }],
              projection: { projection_type: 'ALL' },
              provisioned_throughput: { read_capacity_units: 1, write_capacity_units: 1 }
            }
          ]
        )
        wait_till_table_create(model_class.table_name)
      end

      it 'fails because of index key_schema updates' do
        expect { subject }.to raise_error Mes::Dynamo::InvalidUpdateOperation
      end

      it 'fails because of index key_schema updates' do
        described_class.new(model_class).update(force: true)
        wait_till_table_create(model_class.table_name)

        expect(model_class.describe_table).to eq model_class.table_settings
      end
    end
  end
end
