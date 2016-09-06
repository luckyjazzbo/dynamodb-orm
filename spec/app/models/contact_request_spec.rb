require 'spec_helper'

RSpec.describe Mes::ContactRequest do
  describe '#email_hash' do
    include_context 'with mes tables'

    it 'appends sha1 of email before save' do
      expect(FactoryGirl.create(:contact_request, email: 'abc@gmail.com').email_hash)
        .to eq 'c0d0a32c405c68cb538e3891a3e3bce98887f012'
    end
  end

  describe '#name & #message' do
    include_context 'with mes tables'
    subject { FactoryGirl.create(:contact_request, name: '', message: '') }

    it 'sets them to nil if "" is passed' do
      expect(subject.name).to eq (nil)
      expect(subject.message).to eq (nil)
    end
  end

  describe 'validations' do
    context 'when email invalid' do
      subject { described_class.new(email: 'not-a-email') }

      it 'has email-related errors' do
        expect(subject).not_to be_valid
        expect(subject.errors).to have_key :email
      end
    end
  end
end
