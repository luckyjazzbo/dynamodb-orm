module Mes
  class TransformedResource < ::Mes::Dynamo::Model
    include ::Mes::Dynamo::Timestamps

    table name: "lte-transformed-resources-#{RACK_ENV}",
          primary_key: :content_id

    field :data, default: -> { {} }

    belongs_to :original_resource, class_name: 'Mes::OriginalResource',
                                   foreign_key: :original_resource_uuid

    validates :content_id,             presence: true
    validates :original_resource_uuid, presence: true

    def asset_type
      data['asset_type']
    end
  end
end
