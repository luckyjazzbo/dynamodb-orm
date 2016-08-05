FactoryGirl.define do
  factory :email_token, class: 'Mes::EmailToken' do
    token    { SecureRandom.urlsafe_base64(32) }
    user_id  { SecureRandom.uuid }
    email    'email@example.com'
  end
end
