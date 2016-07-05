module Mes
  class AccessToken < ::Mes::Dynamo::Model
    include ::Mes::Dynamo::Timestamps

    TYPES          = %w(EMBED WEB APP S2S INTERNAL TENANT).freeze
    DEVISE_CLASSES = %w(BROWSER MOBILE SETTOPBOX SMARTTV HBBTV GAMECONSOLE HDMISTICK).freeze
    STATUSES       = %w(valid blocked).freeze

    table name: "mes-access-tokens-#{RACK_ENV}",
          primary_key: :id_token

    field :access_token,  type: :string
    field :tenant_id,     type: :string
    field :active,        type: :boolean, default: true
    field :type,          type: :string,  default: 'EMBED'
    field :device_class,  type: :string,  default: 'BROWSER'
    field :title,         type: :string
    field :app_shop_link, type: :string

    field :s2s_ip_whitelist_range, type: :string_set
    field :s2s_check_remote_ip,    type: :boolean

    field :initialization_vector, type: :string
    field :algorithm_version,     type: :number, default: 1
    field :status,                type: :string, default: 'valid'

    table_index :tenant_id, name: 'tenant_id_index'
    table_index :status,    name: 'status_index'

    before_create do
      # We need 32-chars string, so we should pass 24 as a param to urlsafe_base64
      # because it generates string with length: n*4/3
      self.access_token          ||= SecureRandom.urlsafe_base64(24)
      self.initialization_vector ||= SecureRandom.base58(16)
    end

    validates :id_token,              presence: true
    validates :access_token,          presence: true
    validates :tenant_id,             presence: true
    validates :initialization_vector, presence: true

    validates :type,         inclusion: { in: TYPES }
    validates :device_class, inclusion: { in: DEVISE_CLASSES }
    validates :status,       inclusion: { in: STATUSES }

    class << self
      def create_with_id_token!(attrs = {})
        new(attrs).tap do |token|
          token.assign_id_token!
          token.save!
        end
      end

      def by_tenant_id(tenant_id)
        index('tenant_id_index')
          .where(tenant_id: tenant_id)
          .select(&:active?)
      end
    end

    def assign_id_token!
      self.id_token = Mes::ContentIdServiceClient.new(
        ENV.fetch('CONTENT_ID_SERVICE_URL')
      ).next_access_token_id
    end
  end
end
