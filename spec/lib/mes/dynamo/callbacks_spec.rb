require 'spec_helper'

RSpec.describe Mes::Dynamo::Callbacks do
  include_context \
    'with dynamodb table',
    :sample_table,
    attribute_definitions: [{
      attribute_name: 'content_id',
      attribute_type: 'S'
    }],
    key_schema: [{
      attribute_name: 'content_id',
      key_type: 'HASH'
    }]

  context 'before_create' do
    class ModelWithBeforeCreateCallback < Mes::Dynamo::Model
      table name: :sample_table
      field :counter

      before_create do
        self.counter = (counter || 0) + 1
      end
    end

    let(:model) { ModelWithBeforeCreateCallback.new(content_id: 'before_create') }

    it 'calls before_create only on initial save' do
      model.save
      model.save
      expect(model.counter).to eq 1
    end
  end

  context 'before_save' do
    class ModelWithBeforeSaveCallback < Mes::Dynamo::Model
      table name: :sample_table
      field :counter

      before_save do
        self.counter = (counter || 0) + 1
      end
    end

    let(:model) { ModelWithBeforeSaveCallback.new(content_id: 'before_save') }

    it 'calls before_save callback on each save' do
      model.save
      model.save
      expect(model.counter).to eq 2
    end
  end

  context 'timestamps' do
    class ModelWithTimestamps < Mes::Dynamo::Model
      include Mes::Dynamo::Timestamps
      table name: :sample_table
      field :title
    end

    let(:model) { ModelWithTimestamps.new(content_id: 'timestamps') }

    it 'inits timestamps on creation' do
      model.save
      expect(model.updated_at).not_to be nil
      expect(model.created_at).not_to be nil
    end

    it 'updates updated_at on updates' do
      model.save

      allow(Time).to receive_messages(now: Time.now + 1)

      model.update_attributes(title: 'hello')
      expect(model.created_at).not_to eq model.updated_at
    end
  end
end
