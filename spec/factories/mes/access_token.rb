FactoryGirl.define do
  factory :access_token, class: 'Mes::AccessToken' do
    access_token  { SecureRandom.urlsafe_base64(24) }
    user_id       { SecureRandom.uuid }
    active        { true }
  end
end
