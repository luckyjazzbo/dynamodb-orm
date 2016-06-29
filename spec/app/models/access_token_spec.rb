require 'spec_helper'

RSpec.describe Mes::AccessToken do
  describe '#access_token' do
    subject { described_class.new }

    it 'is generated automaticaly' do
      expect { subject.save }
        .to change { subject.access_token }
        .from(nil)
    end

    it 'is not replacing the manualy set token' do
      subject.access_token = 'some_token'
      expect { subject.save }.not_to change { subject.access_token }
    end

    it 'is generates 32-char string' do
      subject.save
      expect(subject.access_token.size).to eq 32
    end
  end

  describe '.by_user_id' do
    include_context 'with mes tables'

    before do
      described_class.create!(user_id: 'u1')
      described_class.create!(user_id: 'u1')
      described_class.create!(user_id: 'u1', active: false)
      described_class.create!(user_id: 'u2')
    end

    it 'filters tokens by user_id' do
      expect(
        described_class.by_user_id('u1').to_a.size
      ).to eq(2)
    end
  end
end
