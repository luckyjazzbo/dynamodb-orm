FactoryGirl.define do
  factory :contact_request, class: 'Mes::ContactRequest' do
    email        'email@example.com'
    tenant_type  'publisher'
    domain       'example.com'
    name         { SecureRandom.uuid }
    message      { SecureRandom.uuid }
  end
end
