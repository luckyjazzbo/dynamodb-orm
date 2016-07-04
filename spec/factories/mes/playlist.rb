FactoryGirl.define do
  factory :playlist, class: 'Mes::Playlist' do
    uuid          { SecureRandom.uuid }
    tenant_id     { SecureRandom.uuid }
  end
end
