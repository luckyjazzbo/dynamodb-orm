require 'spec_helper'

RSpec.describe Mes::Playlist do
  described_class::TYPES.each do |type|
    describe "##{type}" do
      context 'denies saving duplicates' do
        include_context 'with mes tables'
        let(:title) { SecureRandom.uuid }
        let(:tenant_id) { 't-' + SecureRandom.uuid }
        let(:invalid_playlist) { FactoryGirl.build(:playlist, title: title, tenant_id: tenant_id) }
        let!(:existing_playlist) { FactoryGirl.create(:playlist, title: title, tenant_id: tenant_id) }

        it 'returns validation error' do
          expect(invalid_playlist).not_to be_valid
          expect(invalid_playlist.errors[:title]).to eq ['should be unique within tenant']
        end

        it 'returns does not fail with the same record' do
          expect(existing_playlist).to be_valid
        end
      end

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
