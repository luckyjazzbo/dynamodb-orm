FactoryGirl.define do
  factory :original_resource, class: 'Mes::OriginalResource' do
    uuid       { SecureRandom.uuid }
    content_id { "v-#{SecureRandom.base64}" }
    version    { 1 }
    period     { Mes::PeriodHelper.current }
    data do
      {
        'content_id' => content_id,
        'asset_type' => 'video'
      }
    end
  end
end
