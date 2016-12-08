require 'spec_helper'

RSpec.describe Mes::Playlist do
  described_class::TYPES.each do |type|
    describe "##{type}" do
      xcontext 'denies saving duplicates' do
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

  context 'When playlist is dynamic' do
    subject do
      FactoryGirl.build(:playlist, extra_params.merge(type: :dynamic))
    end

    context 'when query passed' do
      let(:extra_params) { { query: {'some': 'query'}, video_ids: nil } }
      it { is_expected.to be_valid }
    end

    context 'when query not passed' do
      let(:extra_params) { { query: nil, video_ids: nil } }
      it { is_expected.not_to be_valid }
    end

    context 'when video_ids passed' do
      let(:extra_params) { { query: {'some': 'query'}, video_ids: ['v-123', 'v-456', 'v-789'] } }
      it { is_expected.not_to be_valid }
    end
  end

  context 'When playlist is static' do
    subject do
      FactoryGirl.build(:playlist, extra_params.merge(type: :static))
    end

    context 'when video_ids passed' do
      let(:extra_params) { { query: nil, video_ids: ['v-123', 'v-456', 'v-789'] } }
      it { is_expected.to be_valid }
    end

    context 'when video_ids not passed' do
      let(:extra_params) { { query: nil, video_ids: nil } }
      it { is_expected.not_to be_valid }
    end

    context 'when query passed' do
      let(:extra_params) { { query: {'some': 'query'}, video_ids: ['v-123', 'v-456', 'v-789'] } }
      it { is_expected.not_to be_valid }
    end
  end

  describe '#next_playlist_outdated?' do
    context 'when next_playlist_updated_at is nil' do
      subject { FactoryGirl.build(:playlist, next_playlist_updated_at: nil) }
      it { is_expected.to be_next_playlist_outdated }
    end

    context 'when next_playlist_updated_at is more than an hour old' do
      subject { FactoryGirl.build(:playlist, next_playlist_updated_at: Time.now.to_f - 60 * 60 - 1) }
      it { is_expected.to be_next_playlist_outdated }
    end

    context 'when next_playlist_updated_at just now' do
      subject { FactoryGirl.build(:playlist, next_playlist_updated_at: Time.now.to_f) }
      it { is_expected.not_to be_next_playlist_outdated }
    end

    context 'when a playlist was updated after last update of next_playlist' do
      subject { FactoryGirl.build(:playlist, next_playlist_updated_at: Time.now.to_f - 1, updated_at: Time.now.to_f) }
      it { is_expected.to be_next_playlist_outdated }
    end
  end

  describe '#next_playlist_actual?' do
    subject { FactoryGirl.build(:playlist, next_playlist_updated_at: nil) }
    it 'is opposite of next_playlist_outdated?' do
      expect(subject.next_playlist_actual?).to eq(!subject.next_playlist_outdated?)
    end
  end
end
