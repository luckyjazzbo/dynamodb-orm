module Mes
  module Dynamo
    class Model
      extend LookupMethods
      extend TableActions
      extend Callbacks
      include Execution
      include Attributes
      include CRUDActions
      include Enumerable

      def initialize(attrs = {}, opts = {})
        init_attributes(attrs)
        persist! if opts[:persisted]
      end
    end
  end
end
