FactoryGirl.define do
  sequence(:playlist_title) { |n| "Playlist number ##{n}" }

  factory :playlist, class: 'Mes::Playlist' do
    id            { 'pl-' + SecureRandom.urlsafe_base64(16) }
    tenant_id     { 't-' + SecureRandom.urlsafe_base64(16) }
    creator_id    { 't-' + SecureRandom.urlsafe_base64(16) }
    title         { generate :playlist_title }
    type          { Mes::Playlist::TYPES.sample }
    query         { { query: { matchAll: {} } } }
  end
end
