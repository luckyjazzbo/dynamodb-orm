module Mes
  module PeriodHelper
    SECONDS_IN_WEEK = 60 * 60 * 24 * 7

    def self.from_unix_timestamp(timestamp)
      timestamp / SECONDS_IN_WEEK
    end
  end
end
