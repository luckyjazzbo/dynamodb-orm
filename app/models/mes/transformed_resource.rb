module Mes
  class TransformedResource < ::Mes::Dynamo::Model
    include ::Mes::Dynamo::Timestamps

    table name: "lte-transformed-resources-#{RACK_ENV}",
          primary_key: :uuid

    field :asset_type, type: :string
    field :content_id, type: :string
    field :data, default: -> { {} }

    belongs_to :original_resource, class_name: 'Mes::OriginalResource',
                                   foreign_key: :original_resource_uuid

    table_index :content_id, name: 'content_id_index'

    before_create do
      self.uuid ||= SecureRandom.uuid
    end

    validates :asset_type,             presence: true
    validates :content_id,             presence: true
    validates :original_resource_uuid, presence: true

    def self.create_from_original_resource!(original_resource, transformed_data)
      create!(
        uuid: SecureRandom.uuid,
        asset_type: original_resource.data['asset_type'],
        content_id: original_resource.content_id,
        original_resource_uuid: original_resource.uuid,
        data: transformed_data
      )
    end
  end
end
