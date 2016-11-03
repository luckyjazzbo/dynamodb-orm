require 'spec_helper'

RSpec.shared_examples_for 'soft-deletable' do
  before(:each) do
    define_provisioning_for(model_name)
    model_name.create_table!
  end
  after(:each) { model_name.drop_table! }
  let(:uuid) { SecureRandom.uuid }
  let(:title) { 'Just random string' }
  subject! { model_name.create!(uuid: uuid, title: title, field1: 1, field2: 1, field3: 1) }

  describe '#delete' do
    context 'when record is invalid before deletion' do
      before do
        expect(subject).to be_valid
        model_name.validates(:field4, presence: true)
        expect(subject).not_to be_valid
      end

      it 'ignores validations' do
        expect { subject.delete }.to change { model_name.count }.by(-1)
      end

      after { model_name.clear_validators! }
    end

    it 'adds deleted_at_field to object' do
      mocked_time = Time.now
      allow(Time).to receive(:now).and_return mocked_time

      expect { subject.delete }
        .to change { subject.public_send(deleted_at_field) }
        .from(0)
        .to(mocked_time.to_f)
    end

    it 'makes item unpersisted' do
      expect { subject.delete }
        .to change { subject.persisted? }
        .from(true).to(false)
    end

    it 'still keeps it in DB' do
      expect { subject.delete }
        .not_to change { model_name.count_without_soft_deletion }
        .from(1)
    end
  end

  describe '#delete_without_soft_deletion' do
    it 'makes item unpersisted' do
      expect { subject.delete_without_soft_deletion }
        .to change { subject.persisted? }
        .from(true)
        .to(false)
    end

    it 'removes item from DB' do
      expect { subject.delete_without_soft_deletion }
        .to change { model_name.count_without_soft_deletion }
        .from(1).to(0)
    end
  end

  describe '#find' do
    it 'should not find item after deletion' do
      subject.delete
      expect(model_name.find_without_soft_deletion(uuid)).not_to be_nil
      expect(model_name.find(uuid)).to be_nil
    end

    it 'should not find unexisting item' do
      subject.delete_without_soft_deletion
      expect(model_name.find_without_soft_deletion(uuid)).to be_nil
      expect(model_name.find(uuid)).to be_nil
    end

    it 'is able to load item when not deleted' do
      expect(model_name.find(uuid).title).to eq title
    end
  end

  describe '#find!' do
    it 'should not find item after deletion' do
      subject.delete
      expect { model_name.find!(uuid) }
        .to raise_error Mes::Dynamo::RecordNotFound
    end

    it 'should not find unexisting item' do
      subject.delete_without_soft_deletion
      expect { model_name.find!(uuid) }
        .to raise_error Mes::Dynamo::RecordNotFound
    end

    it 'is able to load item when not deleted' do
      expect(model_name.find!(uuid).title).to eq title
    end
  end

  describe '#count' do
    it 'should not include soft-deleted items' do
      expect { subject.delete }
        .to change { model_name.count }
        .from(1).to(0)
    end
  end

  describe '#chain' do
    before do
      model_name.create!(uuid: SecureRandom.uuid, title: title + '1', field1: 1, field2: 1, field3: 1)
      model_name.create!(uuid: SecureRandom.uuid, title: title + '2', field1: 2, field2: 2, field3: 2)
      model_name.create!(uuid: SecureRandom.uuid, title: title + '3', field1: 3, field2: 3, field3: 3)
    end

    context 'requests without filters' do
      before do
        expect_any_instance_of(Mes::Dynamo::Chain).not_to receive :filter
      end

      it 'allows to query within index with name' do
        expect { subject.delete }
          .to change { model_name.index('field1_index').where(field1: 1).count }
          .from(2).to(1)
      end

      it 'allows to query within index without name' do
        expect { subject.delete }
          .to change { model_name.index('field2_index').where(field2: 1).count }
          .from(2).to(1)
      end
    end
    it 'allows to query within index with range' do
      expect { subject.delete }
        .to change { model_name.index('field3_field2_index').where(field3: 1, field2: 1).count }
        .from(2).to(1)
    end

    it 'returns all field' do
      expect(
        model_name.index('field1_index').where(field1: 1).map(&:title)
      ).to match_array [title, title + '1']
    end
  end
end

RSpec.describe Mes::Dynamo::Model do
  context 'with default deleted_at_field' do
    it_behaves_like 'soft-deletable' do
      class SampleObject < Mes::Dynamo::Model
        acts_as_soft_deletable

        table name: 'sample_objects', primary_key: :uuid

        field :title, type: :string
        field :field1, type: :float
        field :field2, type: :float
        field :field3, type: :float
        field :field4, type: :float

        table_index :field1
        table_index :field2, name: 'field2_index'
        table_index :field3, range: [:field2], name: 'field3_field2_index'
      end

      let(:model_name) { SampleObject }
      let(:deleted_at_field) { :deleted_at }
    end
  end

  context 'with custom deleted_at_field' do
    it_behaves_like 'soft-deletable' do
      class OtherSampleObject < Mes::Dynamo::Model
        acts_as_soft_deletable(field: :destroyed_at)

        table name: 'sample_objects', primary_key: :uuid

        field :title, type: :string
        field :field1, type: :float
        field :field2, type: :float
        field :field3, type: :float
        field :field4, type: :float

        table_index :field1
        table_index :field2, name: 'field2_index'
        table_index :field3, range: [:field2], name: 'field3_field2_index'
      end

      let(:model_name) { OtherSampleObject }
      let(:deleted_at_field) { :destroyed_at }
    end
  end

  context 'without soft-deletion' do
    class OneMoreSampleObject < Mes::Dynamo::Model
      table name: 'sample_objects', primary_key: :uuid
      field :title, type: :string
    end

    let(:model_name) { OneMoreSampleObject }

    context 'does not include soft-deletion' do
      context 'class methods' do
        subject { model_name }
        it { is_expected.not_to respond_to(:count_without_soft_deletion) }
        it { is_expected.not_to respond_to(:count_with_soft_deletion) }
      end

      context 'instance methods' do
        subject { model_name.new }
        it { is_expected.not_to respond_to(:delete_without_soft_deletion) }
        it { is_expected.not_to respond_to(:delete_with_soft_deletion) }
      end
    end
  end
end
