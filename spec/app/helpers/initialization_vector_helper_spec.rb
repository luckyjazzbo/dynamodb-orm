require 'spec_helper'

RSpec.describe Mes::InitializationVectorHelper do
  describe '.generate' do
    it 'generates string of lengths 16' do
      expect(described_class.generate.length).to eq(16)
    end

    it 'contains only letters and numbers' do
      expect(described_class.generate).to match(/\A[a-zA-Z0-9]{16}\z/)
    end

    it 'generates diffenent strings each time' do
      expect(described_class.generate).not_to eq(described_class.generate)
    end
  end
end
