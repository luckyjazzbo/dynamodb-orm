class TransformationStep
  include Mes::Dynamo::Model
  include Mes::Dynamo::Timestamps

  table name: "lte-document-versions-store-#{RACK_ENV}", primary_key: :uuid

  field :content_id
  field :data
  field :original_resource_uuid
  field :step

  before_create do
    self.uuid ||= SecureRandom.uuid
  end
end
