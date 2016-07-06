FactoryGirl.define do
  sequence(:playlist_title) { |n| "Playlist number ##{n}" }

  factory :playlist, class: 'Mes::Playlist' do
    id            { 'p-' + SecureRandom.urlsafe_base64(16) }
    tenant_id     { SecureRandom.uuid }
    title         { generate :playlist_title }
    type          { Mes::Playlist::TYPES.sample }
    query         { { query: { matchAll: {} } } }
  end
end
