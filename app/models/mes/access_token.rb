module Mes
  class AccessToken < ::Mes::Dynamo::Model
    include ::Mes::Dynamo::Timestamps

    table name: "mes-access-tokens-#{RACK_ENV}", primary_key: :access_token

    field :user_id, type: :string
    field :active, type: :boolean, default: true

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
