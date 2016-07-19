FactoryGirl.define do
  factory :transformed_resource, class: 'Mes::TransformedResource' do
    transient do
      original_resource { create(:original_resource) }
    end

    content_id             { original_resource.content_id }
    original_resource_uuid { original_resource.uuid }
    data do
      {
        'asset_type' => 'video',
        'modified_at' => 123343252.0,
        'clip_duration' => 12312.0,
        'image' => { 'url' => 'http://image.example.com/image' },
        'id' => content_id
      }
    end
  end
end
