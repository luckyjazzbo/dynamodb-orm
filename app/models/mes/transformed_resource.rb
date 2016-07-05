module Mes
  class TransformedResource < ::Mes::Dynamo::Model
    include ::Mes::Dynamo::Timestamps

    table name: "lte-transformed-resources-#{RACK_ENV}",
          primary_key: :content_id

    field :original_resource_uuid, type: :string
    field :data, default: -> { {} }

    validates :content_id,             presence: true
    validates :original_resource_uuid, presence: true

    def asset_type
      data['asset_type']
    end
  end
end
