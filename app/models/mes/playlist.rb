module Mes
  class Playlist < ::Mes::Dynamo::Model
    include ::Mes::Dynamo::Timestamps

    TYPES = %w(dynamic static).freeze

    table name: "mes-playlists-#{RACK_ENV}",
          primary_key: :uuid

    field :tenant_id, type: :string
    field :title,     type: :string
    field :type,      type: :string
    field :query,     type: :map

    table_index :tenant_id, name: 'tenant_id_index'

    before_create do
      self.uuid ||= SecureRandom.uuid
    end

    validates :tenant_id, presence: true
    validates :title,     presence: true
    validates :query,     presence: true
    validates :type,      presence: true, inclusion: { in: TYPES }

    def self.by_tenant_id(tenant_id)
      index('tenant_id_index')
        .where(tenant_id: tenant_id)
    end
  end
end
