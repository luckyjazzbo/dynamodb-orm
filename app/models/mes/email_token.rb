module Mes
  class EmailToken < ::Mes::Dynamo::Model
    include ::Mes::Dynamo::Timestamps
    acts_as_soft_deletable(field: :used_at)

    table name: "mes-email-tokens-#{RACK_ENV}",
          primary_key: :token

    field :email,   type: :string
    field :user_id, type: :string

    before_create do
      self.token ||= SecureRandom.urlsafe_base64(32)
    end

    validates :email,   presence: true, email: true
    validates :user_id, presence: true
  end
end
