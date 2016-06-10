module Mes
  class TransformedResource
    include Mes::Dynamo::Model
    include Mes::Dynamo::Timestamps

    table name: "lte-transformed-resources-#{RACK_ENV}", primary_key: :content_id

    field :data
    field :original_resource_uuid
  end
end
