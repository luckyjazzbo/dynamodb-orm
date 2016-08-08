require 'spec_helper'

RSpec.describe EmailValidator do
  let(:sample_model) do
    Class.new do
      include ActiveModel::Model
      attr_accessor :email
    end.new
  end

  subject { described_class.new(attributes: [:email]) }

  describe '.validate_each' do
    context 'when valid' do
      it 'does not add errors' do
        expect {
          subject.validate_each(sample_model, :email, 'email@example.com')
        }.not_to change {
          sample_model.errors[:email]
        }
      end
    end

    context 'when invalid' do
      it 'adds errors' do
        expect {
          subject.validate_each(sample_model, :email, '@invalid.email')
        }.to change {
          sample_model.errors[:email]
        }
      end
    end
  end
end
