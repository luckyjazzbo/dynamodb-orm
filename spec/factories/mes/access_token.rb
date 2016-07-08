FactoryGirl.define do
  factory :access_token, class: 'Mes::AccessToken' do
    id            { 'x-' + SecureRandom.urlsafe_base64(16) }
    access_token  { SecureRandom.urlsafe_base64(24) }
    tenant_id     { SecureRandom.uuid }

    initialization_vector { 'asdf1234asdf1234' }
  end
end
