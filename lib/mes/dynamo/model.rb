module Mes
  module Dynamo
    class Model
      extend LookupMethods
      extend TableActions
      extend Callbacks
      extend Relations
      extend AllowsSoftDeletion
      include ActiveModel::Validations
      include LookupMethods::InstanceMethods
      include Execution
      include Attributes
      include CRUDActions
      include Enumerable
      include Comparable

      def initialize(attrs = {}, opts = {})
        init_attributes(attrs)
        persist! if opts[:persisted]
        cls.run_callbacks(self, :after_initialize)
      end

      def self.logger
        Mes::Dynamo.logger
      end

      def logger
        cls.logger
      end
    end
  end
end
