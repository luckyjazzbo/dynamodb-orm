module Mes
  class AccessToken < ::Mes::Dynamo::Model
    include ::Mes::Dynamo::Timestamps

    TYPES = %w(EMBED WEB APP S2S INTERNAL TENANT).freeze
    DEVISE_CLASSES = %w(BROWSER MOBILE SETTOPBOX SMARTTV HBBTV GAMECONSOLE HDMISTICK).freeze

    table name: "mes-access-tokens-#{RACK_ENV}", primary_key: :access_token

    field :user_id,       type: :string
    field :active,        type: :boolean, default: true
    field :type,          type: :string,  default: 'EMBED'
    field :device_class,  type: :string,  default: 'BROWSER'
    field :title,         type: :string
    field :app_shop_link, type: :string
    field :s2s_ip_whitelist_range, type: :string_set
    field :s2s_check_remote_ip,    type: :boolean

    table_index :user_id, name: 'user_id_index'

    before_create do
      # We need 32-chars string, so we should pass 24 as a param to urlsafe_base64
      # because it generates string with length: n*4/3
      self.access_token ||= SecureRandom.urlsafe_base64(24)
    end

    def self.by_user_id(user_id)
      index('user_id_index')
        .where(user_id: user_id)
        .select(&:active?)
    end
  end
end
