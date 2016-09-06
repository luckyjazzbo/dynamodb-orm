require 'digest/sha1'

module Mes
  class ContactRequest < ::Mes::Dynamo::Model
    include ::Mes::Dynamo::Timestamps
    CONTACT_REQUEST_TYPES = %w(content_owner publisher).freeze

    table name: "mes-contact-requests-#{RACK_ENV}",
          primary_key: :uuid

    field :email,      type: :string
    field :email_hash, type: :string
    field :type,       type: :string
    field :domain,     type: :string
    field :name,       type: :string
    field :message,    type: :string

    validates :email,  presence: true, email: true
    validates :type,   presence: true, inclusion: { in: CONTACT_REQUEST_TYPES }
    validates :domain, presence: true

    before_create do
      self.uuid ||= SecureRandom.uuid
    end

    before_save do
      self.email_hash = Digest::SHA1.hexdigest(email)
    end
  end
end
