module Mes
  class Playlist < Mes::Dynamo::Model
    include Mes::ContentId
    include Mes::Dynamo::Timestamps
    acts_as_soft_deletable

    TYPES = %w(dynamic static).freeze
    NEXT_PLAYLIST_UPDATE_INTERVAL_SECONDS = 60 * 60

    table name: "mes-playlists-#{RACK_ENV}"

    field :parent_id,                  type: :string
    field :tenant_id,                  type: :string
    field :creator_id,                 type: :string

    field :title,                      type: :string
    field :type,                       type: :string
    field :query,                      type: :map

    field :next_playlist_updated_at, type: :float

    belongs_to :next_playlist, class_name: 'Mes::Playlist',
                               foreign_key: :next_playlist_id # TODO: Rename to next_playlist_uuid

    table_index :parent_id, name: 'parent_id_index'
    table_index :tenant_id, name: 'tenant_id_index'
    table_index :tenant_id, range: [:title]

    validates :tenant_id,  presence: true
    validates :creator_id, presence: true
    validates :title,      presence: true
    validates :query,      presence: true
    validates :type,       presence: true, inclusion: { in: TYPES }

    # validate :uniqueness_of_title_in_tenant_scope

    def uniqueness_of_title_in_tenant_scope
      return if parent_id # skip this validation for recommendation playlists
      duplicates = self.class.index(:tenant_id_title_index)
                       .where(tenant_id: tenant_id, title: title)
                       .filter('id <> :id', id: id)
                       .filter('attribute_not_exists(parent_id)')
      errors.add(:title, 'should be unique within tenant') if duplicates.count > 0
    end

    def dynamic?
      type == 'dynamic'
    end

    def static?
      type == 'static'
    end

    def next_playlist_outdated?
      (updated_at.to_f > next_playlist_updated_at.to_f) ||
        (Time.now.to_f - next_playlist_updated_at.to_f > NEXT_PLAYLIST_UPDATE_INTERVAL_SECONDS)
    end

    def next_playlist_actual?
      !next_playlist_outdated?
    end

    def asset_type
      'playlist'
    end

    class << self
      def by_tenant_id(tenant_id)
        find_by(:tenant_id, tenant_id)
      end

      def by_parent_id(parent_id)
        find_by(:parent_id, parent_id)
      end
    end
  end
end
