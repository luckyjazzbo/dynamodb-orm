module Mes
  class TransformedResource < ::Mes::Dynamo::Model
    include ::Mes::Dynamo::Timestamps

    table name: "lte-transformed-resources-#{RACK_ENV}",
          primary_key: :uuid

    field :content_id, type: :string
    field :data, default: -> { {} }

    belongs_to :original_resource, class_name: 'Mes::OriginalResource',
                                   foreign_key: :original_resource_uuid

    table_index :content_id, name: 'content_id_at_index'

    before_create do
      self.uuid ||= SecureRandom.uuid
    end

    validates :content_id,             presence: true
    validates :original_resource_uuid, presence: true

    def self.create_from_original_resource!(original_resource, transformed_data)
      create!(
        uuid: SecureRandom.uuid,
        content_id: original_resource.content_id,
        original_resource_uuid: original_resource.uuid,
        data: transformed_data
      )
    end

    def asset_type
      data['asset_type']
    end
  end
end
