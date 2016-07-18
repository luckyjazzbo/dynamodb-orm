module Mes
  class AccessToken < ::Mes::Dynamo::Model
    include ::Mes::ContentId
    include ::Mes::Dynamo::Timestamps
    acts_as_soft_deletable(field: :deactivated_at)

    TYPES          = %w(EMBED WEB APP S2S INTERNAL TENANT).freeze
    DEVISE_CLASSES = %w(BROWSER MOBILE SETTOPBOX SMARTTV HBBTV GAMECONSOLE HDMISTICK).freeze
    STATUSES       = %w(VALID DEACTIVATED).freeze

    table name: "mes-access-tokens-#{RACK_ENV}"

    field :access_token,  type: :string
    field :tenant_id,     type: :string
    field :type,          type: :string,  default: 'EMBED'
    field :device_class,  type: :string,  default: 'BROWSER'
    field :title,         type: :string
    field :app_shop_link, type: :string

    field :s2s_ip_whitelist_range, type: :string_set
    field :s2s_check_remote_ip,    type: :boolean

    field :initialization_vector, type: :string
    field :algorithm_version,     type: :integer, default: 1

    table_index :tenant_id, name: 'tenant_id_index'

    before_create do
      # We need 32-chars string, so we should pass 24 as a param to urlsafe_base64
      # because it generates string with length: n*4/3
      self.access_token          ||= SecureRandom.urlsafe_base64(24)
      self.initialization_vector ||= SecureRandom.base58(16)
    end

    validates :access_token,          presence: true
    validates :tenant_id,             presence: true
    validates :initialization_vector, presence: true

    validates :type,         inclusion: { in: TYPES }
    validates :device_class, inclusion: { in: DEVISE_CLASSES }

    def active?
      deactivated_at == 0
    end

    def status
      active? ? 'VALID' : 'DEACTIVATED'
    end

    def asset_type
      'access_token'
    end

    class << self
      def by_tenant_id(tenant_id)
        index('tenant_id_index').where(tenant_id: tenant_id)
      end
    end
  end
end
