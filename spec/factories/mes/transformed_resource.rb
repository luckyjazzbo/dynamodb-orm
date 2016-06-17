FactoryGirl.define do
  factory :transformed_resource, class: 'Mes::TransformedResource' do
    transient do
      original_resource { create(:original_resource) }
    end

    content_id             { original_resource.content_id }
    original_resource_uuid { original_resource.uuid }
    data                   { original_resource.data }
  end
end
