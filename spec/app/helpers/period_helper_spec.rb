require 'spec_helper'

RSpec.describe Mes::PeriodHelper do
  describe '.from_unix_timestamp' do
    it 'calculates partition for 0' do
      expect(
        described_class.from_unix_timestamp(0)
      ).to eq(0)
    end

    it 'returns integers' do
      expect(
        described_class.from_unix_timestamp(Time.now)
      ).to be_an(Integer)
    end

    it 'works with floats' do
      expect(
        described_class.from_unix_timestamp(1466342644.227963)
      ).to eq(2424)
    end

    it 'calculates different values for different weeks' do
      expect(
        described_class.from_unix_timestamp(Time.now)
      ).not_to eq(
        described_class.from_unix_timestamp(Time.now - 1.week)
      )
    end
  end

  describe '.current' do
    before do
      allow(Time).to receive(:now).and_return(Time.now)
    end

    it 'returns current period' do
      expect(
        described_class.current
      ).to eq(
        described_class.from_unix_timestamp(Time.now)
      )
    end
  end
end
