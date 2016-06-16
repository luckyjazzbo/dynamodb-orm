module Mes
  class TransformedResource < ::Mes::Dynamo::Model
    include ::Mes::Dynamo::Timestamps

    table name: "lte-transformed-resources-#{RACK_ENV}", primary_key: :content_id

    field :data
    field :original_resource_uuid, type: :string
  end
end
