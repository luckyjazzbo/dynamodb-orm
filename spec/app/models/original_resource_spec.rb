require 'spec_helper'

RSpec.describe Mes::OriginalResource do
  describe '#period' do
    subject { Mes::OriginalResource.new(uuid: 'xxx', data: {}) }

    it 'empty by default' do
      expect(subject.period).to be_nil
    end

    it 'assigns on save' do
      subject.save

      Timecop.freeze do
        expect(subject.period).to eq(
          Mes::PeriodHelper.from_unix_timestamp(Time.now.to_i)
        )
      end
    end
  end

  describe '#asset_type' do
    context 'by default' do
      it 'expected to be nil' do
        expect(subject.asset_type).to be_nil
      end
    end

    context 'when present' do
      subject { described_class.new(data: { 'asset_type' => 'video' }) }

      it 'is not nil' do
        expect(subject.asset_type).to eq('video')
      end
    end
  end
end
