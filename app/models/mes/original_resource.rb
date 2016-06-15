module Mes
  class OriginalResource < ::Mes::Dynamo::Model
    include Mes::Dynamo::Timestamps

    table name: "lte-original-resources-#{RACK_ENV}", primary_key: :uuid

    field :content_id, type: 'S'
    field :data

    index :content_id

    before_create do
      self.uuid ||= SecureRandom.uuid
    end
  end
end
