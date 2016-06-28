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
end
