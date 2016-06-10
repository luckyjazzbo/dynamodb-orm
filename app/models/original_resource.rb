class OriginalResource
  include LteCore::DynamoDB::Model
  include LteCore::DynamoDB::Timestamps

  table name: "lte-document-store-#{App.env}", primary_key: :uuid

  field :content_id
  field :data

  before_create do
    self.uuid ||= SecureRandom.uuid
  end
end
