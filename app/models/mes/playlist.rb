module Mes
  class Playlist < ::Mes::Dynamo::Model
    include ::Mes::Dynamo::Timestamps

    table name: "mes-playlists-#{RACK_ENV}", primary_key: :uuid
    field :tenant_id, type: :string

    before_create do
      self.uuid ||= SecureRandom.uuid
    end
  end
end
