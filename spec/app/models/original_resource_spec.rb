require 'spec_helper'

RSpec.describe Mes::OriginalResource do
  describe '#period' do
    subject { Mes::OriginalResource.new(context_id: 'xxx', data: {}) }

    before do
      allow(Time).to receive_messages(now: Time.now)
    end

    it 'empty by default' do
      expect(subject.period).to be_nil
    end

    it 'assigns on save' do
      subject.save

      expect(subject.period).to eq(
        ::Mes::PeriodHelper.from_unix_timestamp(Time.now.to_i)
      )
    end
  end
end
