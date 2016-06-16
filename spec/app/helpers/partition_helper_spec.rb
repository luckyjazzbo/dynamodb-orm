require 'spec_helper'

RSpec.describe Mes::PartitionHelper do
  describe '.from_unix_timestamp' do
    it 'calculates partition for 0' do
      expect(
        described_class.from_unix_timestamp(0)
      ).to eq 0
    end

    it 'calculates different values for different weeks' do
      expect(
        described_class.from_unix_timestamp(Time.now.to_i)
      ).not_to eq(
        described_class.from_unix_timestamp((Time.now - 1.week).to_i)
      )
    end
  end
end
