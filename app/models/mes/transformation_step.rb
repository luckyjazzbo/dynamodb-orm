module Mes
  class TransformationStep < ::Mes::Dynamo::Model
    include ::Mes::Dynamo::Timestamps

    table name: "lte-transformation-steps-#{RACK_ENV}", primary_key: :uuid

    field :content_id, type: :string
    field :original_resource_uuid, type: :string
    field :step
    field :data, default: -> { {} }

    before_create do
      self.uuid ||= SecureRandom.uuid
    end

    def asset_type
      data['asset_type']
    end
  end
end
