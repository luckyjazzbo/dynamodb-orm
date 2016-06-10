class TransformedResource
  include LteCore::DynamoDB::Model
  include LteCore::DynamoDB::Timestamps

  table name: "lte-document-versions-store-#{RACK_ENV}", primary_key: :content_id

  field :data
  field :original_resource_uuid
end
