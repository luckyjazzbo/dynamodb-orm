module Mes
  module ContentId
    extend ActiveSupport::Concern

    included do
      validates :id, presence: true
    end

    def assign_id!
      self.id = Mes::ContentIdServiceClient.new(
        ENV.fetch('CONTENT_ID_SERVICE_URL')
      ).next_access_token_id
    end

    class_methods do
      def create_with_id!(attrs = {})
        generic_create_with_id(attrs, true)
      end

      def create_with_id(attrs = {})
        generic_create_with_id(attrs, false)
      end

      private

      def generic_create_with_id(attrs, raise_exceptions)
        new(attrs).tap do |object|
          object.assign_id!
          raise_exceptions ? object.save! : object.save
        end
      end
    end
  end
end
