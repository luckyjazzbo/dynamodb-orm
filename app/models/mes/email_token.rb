module Mes
  class EmailToken < ::Mes::Dynamo::Model
    include ::Mes::Dynamo::Timestamps
    acts_as_soft_deletable(field: :used_at)

    EXPIRES_IN_SECONDS = 60 * 60 * 24

    table name: "mes-email-tokens-#{RACK_ENV}",
          primary_key: :token

    field :email,   type: :string
    field :user_id, type: :string

    after_initialize do
      self.token ||= SecureRandom.urlsafe_base64(32)
    end

    validates :token,   presence: true
    validates :email,   presence: true, email: true
    validates :user_id, presence: true

    alias_method :used?, :deleted?
    alias_method :mark_as_used!, :delete_with_soft_deletion

    def usable?
      !used? && Time.now.to_f < created_at.to_f + EXPIRES_IN_SECONDS
    end
  end
end
