module Mes
  class Playlist < ::Mes::Dynamo::Model
    include ::Mes::Dynamo::Timestamps

    table name: "mes-playlists-#{RACK_ENV}", primary_key: :uuid
    field :tenant_id, type: :string
    field :query, type: :map

    table_index :tenant_id, name: 'tenant_id_index'

    before_create do
      self.uuid ||= SecureRandom.uuid
    end
  end
end
