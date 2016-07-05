FactoryGirl.define do
  factory :transformation_step, class: 'Mes::TransformationStep' do
    transient do
      original_resource { create(:original_resource) }
    end

    uuid                   { SecureRandom.uuid }
    content_id             { original_resource.content_id }
    original_resource_uuid { original_resource.uuid }
    step                   { 'initial' }
    data                   { original_resource.data }
  end
end
