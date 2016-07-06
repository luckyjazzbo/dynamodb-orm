require 'spec_helper'

RSpec.describe Mes::Dynamo::Model do
  class SampleObject < Mes::Dynamo::Model
    include Mes::Dynamo::SoftDeletion
    table name: 'sample_objects', primary_key: :uuid
    field :title, type: :string
    field :field1, type: :number
    table_index :field1
    field :field2, type: :number
    table_index :field2, name: 'field2_index'
  end

  before(:each) { SampleObject.create_table! }
  after(:each) { SampleObject.drop_table! }

  let(:uuid) { SecureRandom.uuid }
  let(:title) { 'Just random string' }

  subject! { SampleObject.create!(uuid: uuid, title: title, field1: 1, field2: 1) }

  describe '#delete' do
    it 'adds deleted_at to object' do
      mocked_time = Time.now
      allow(Time).to receive(:now).and_return mocked_time

      expect { subject.delete }
        .to change { subject.deleted_at }
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
        .not_to change { SampleObject.count_without_soft_deletion }
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
        .to change { SampleObject.count_without_soft_deletion }
        .from(1).to(0)
    end
  end

  describe '#find' do
    it 'should not find item after deletion' do
      subject.delete
      expect(SampleObject.find_without_soft_deletion(uuid)).not_to be_nil
      expect(SampleObject.find(uuid)).to be_nil
    end

    it 'should not find unexisting item' do
      subject.delete_without_soft_deletion
      expect(SampleObject.find_without_soft_deletion(uuid)).to be_nil
      expect(SampleObject.find(uuid)).to be_nil
    end

    it 'is able to load item when not deleted' do
      expect(SampleObject.find(uuid).title).to eq title
    end
  end

  describe '#find!' do
    it 'should not find item after deletion' do
      subject.delete
      expect { SampleObject.find!(uuid) }
        .to raise_error Mes::Dynamo::RecordNotFound
    end

    it 'should not find unexisting item' do
      subject.delete_without_soft_deletion
      expect { SampleObject.find!(uuid) }
        .to raise_error Mes::Dynamo::RecordNotFound
    end

    it 'is able to load item when not deleted' do
      expect(SampleObject.find!(uuid).title).to eq title
    end
  end

  describe '#count' do
    it 'should not include soft-deleted items' do
      expect { subject.delete }
        .to change { SampleObject.count }
        .from(1).to(0)
    end
  end

  describe '#chain' do
    before do
      SampleObject.create!(uuid: SecureRandom.uuid, title: title + '1', field1: 1, field2: 1)
      SampleObject.create!(uuid: SecureRandom.uuid, title: title + '2', field1: 2, field2: 2)
      SampleObject.create!(uuid: SecureRandom.uuid, title: title + '3', field1: 3, field2: 3)
    end

    it 'allows to query within index with name' do
      expect { subject.delete }
        .to change { SampleObject.index('field1_index').where(field1: 1).count }
        .from(2).to(1)
    end

    it 'allows to query within index without name' do
      expect { subject.delete }
        .to change { SampleObject.index('field2_index').where(field2: 1).count }
        .from(2).to(1)
    end

    it 'returns all field' do
      expect(
        SampleObject.index('field1_index').where(field1: 1).map(&:title)
      ).to match_array [title, title + '1']
    end
  end
end
