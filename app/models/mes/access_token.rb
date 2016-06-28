module Mes
  class AccessToken < ::Mes::Dynamo::Model
    include ::Mes::Dynamo::Timestamps

    table name: "mes-access-tokens-#{RACK_ENV}", primary_key: :access_token

    field :user_id, type: :string

    before_create do
      # We need 32-chars string, so we should pass 24 as a param to urlsafe_base64
      # because it generates string with length: n*4/3
      self.access_token ||= SecureRandom.urlsafe_base64(24)
    end
  end
end
