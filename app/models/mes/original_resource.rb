module Mes
  class OriginalResource < ::Mes::Dynamo::Model
    include Mes::Dynamo::Timestamps

    table name: "lte-original-resources-#{RACK_ENV}", primary_key: :uuid

    field :content_id, type: 'S'
    field :partition, type: 'N'
    field :data

    index :partition, range: :created_at, name: 'partition_created_at_index'

    before_create do
      self.uuid ||= SecureRandom.uuid
    end

    before_save do
      self.partition = ::Mes::PartitionHelper.from_unix_timestamp(created_at || Time.now.to_i)
    end
  end
end
