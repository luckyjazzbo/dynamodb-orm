module Mes
  module PeriodHelper
    SECONDS_IN_WEEK = 60 * 60 * 24 * 7

    def self.from_unix_timestamp(timestamp)
      timestamp.to_i / SECONDS_IN_WEEK
    end

    def self.current
      from_unix_timestamp(Time.now)
    end
  end
end
