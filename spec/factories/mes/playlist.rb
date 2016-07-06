FactoryGirl.define do
  sequence(:playlist_title) { |n| "Playlist number ##{n}" }

  factory :playlist, class: 'Mes::Playlist' do
    uuid          { SecureRandom.uuid }
    tenant_id     { SecureRandom.uuid }
    title         { generate :playlist_title }
    type          { Mes::Playlist::TYPES.sample }
    query         { { query: { matchAll: {} } } }
  end
end
