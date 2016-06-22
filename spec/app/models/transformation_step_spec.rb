require 'spec_helper'

RSpec.describe Mes::TransformationStep do
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
