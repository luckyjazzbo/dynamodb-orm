module Mes
  class Playlist < ::Mes::Dynamo::Model
    include ::Mes::ContentId
    include ::Mes::Dynamo::Timestamps
    acts_as_soft_deletable

    TYPES = %w(dynamic static).freeze

    table name: "mes-playlists-#{RACK_ENV}"

    field :parent_id,                  type: :string
    field :tenant_id,                  type: :string
    field :creator_id,                 type: :string

    field :next_playlist_id,           type: :string
    field :next_playlist_updated_at,   type: :float

    field :title,                      type: :string
    field :type,                       type: :string
    field :query,                      type: :map

    table_index :parent_id, name: 'parent_id_index'
    table_index :tenant_id, name: 'tenant_id_index'
    table_index :tenant_id, range: [:title]

    validates :tenant_id,  presence: true
    validates :creator_id, presence: true
    validates :title,      presence: true
    validates :query,      presence: true
    validates :type,       presence: true, inclusion: { in: TYPES }

    validate :uniqueness_of_title_in_tenant_scope

    def uniqueness_of_title_in_tenant_scope
      return if parent_id # skip this validation for recommendation playlists
      duplicates = self.class.index(:tenant_id_title_index)
                       .where(tenant_id: tenant_id, title: title)
      errors.add(:title, 'should be unique within tenant') if duplicates.count > 0
    end

    def dynamic?
      type == 'dynamic'
    end

    def static?
      type == 'static'
    end

    class << self
      def by_tenant_id(tenant_id)
        find_by(:tenant_id, tenant_id)
      end

      def by_parent_id(parent_id)
        find_by(:parent_id, parent_id)
      end
    end

    def asset_type
      'playlist'
    end
  end
end
