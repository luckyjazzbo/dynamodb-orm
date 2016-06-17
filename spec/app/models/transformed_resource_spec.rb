require 'spec_helper'

RSpec.describe Mes::TransformedResource do
  describe '#asset_type' do
    context 'by default' do
      it 'expected to be nil' do
        expect(subject.asset_type).to be_nil
      end
    end
  end
end
