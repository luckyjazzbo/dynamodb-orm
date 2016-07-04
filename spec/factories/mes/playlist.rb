FactoryGirl.define do
  factory :playlist, class: 'Mes::Playlist' do
    uuid          { SecureRandom.uuid }
    tenant_id     { SecureRandom.uuid }
    query         { { some: ['json', 'data'] } }
  end
end
