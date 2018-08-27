module DynamodbOrm
  module Timestamps
    def self.included(base)
      base.field :created_at, type: :float
      base.field :updated_at, type: :float

      base.before_create do
        self.created_at = attributes[:created_at] || current_time
      end

      base.before_save do
        passed_value = updated_at_changed? ? read_attribute(:updated_at) : nil
        write_attribute :updated_at, (passed_value || current_time)
        reset_updated_at_changed
      end
    end

    def updated_at=(timestamp)
      updated_at_changed!
      write_attribute :updated_at, timestamp
    end

    private

    def updated_at_changed!
      @updated_at_changed = true
    end

    def updated_at_changed?
      @updated_at_changed
    end

    def reset_updated_at_changed
      @updated_at_changed = nil
    end

    def current_time
      Time.now.to_f
    end
  end
end
