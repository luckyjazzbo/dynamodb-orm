require 'spec_helper'

RSpec.describe Mes::EmailToken do
  describe '#used?' do
    context 'when new' do
      subject { described_class.new.used? }
      it { is_expected.to eq(false) }
    end

    context 'when used_at is set' do
      subject { described_class.new(used_at: Time.now.to_f).used? }
      it { is_expected.to eq(true) }
    end
  end

  describe '#usable?' do
    context 'when usable' do
      subject { described_class.new(created_at: Time.now.to_f).usable? }
      it { is_expected.to eq(true) }
    end

    context 'when not usable' do
      context 'when used' do
        subject { described_class.new(created_at: Time.now.to_f, used_at: Time.now.to_f).usable? }
        it { is_expected.to eq(false) }
      end

      context 'when expired' do
        subject { described_class.new(created_at: Time.now.to_f - described_class::EXPIRES_IN_SECONDS - 60).usable? }
        it { is_expected.to eq(false) }
      end
    end
  end
end
