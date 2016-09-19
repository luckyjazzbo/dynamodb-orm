require 'spec_helper'

RSpec.describe Mes::Playlist do
  described_class::TYPES.each do |type|
    describe "##{type}" do
      it "responds to #{type}" do
        is_expected.to respond_to("#{type}?")
      end

      context 'when true' do
        before do
          subject.type = type
        end

        it { expect(subject.send("#{type}?")).to eq(true) }
      end

      context 'when false' do
        before do
          subject.type = 'random'
        end

        it { expect(subject.send("#{type}?")).to eq(false) }
      end
    end
  end
end
