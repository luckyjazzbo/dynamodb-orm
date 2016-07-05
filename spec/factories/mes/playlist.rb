FactoryGirl.define do
  factory :playlist, class: 'Mes::Playlist' do
    uuid          { SecureRandom.uuid }
    tenant_id     { SecureRandom.uuid }
    query         { { query: { matchAll: {} } } }
  end
end
