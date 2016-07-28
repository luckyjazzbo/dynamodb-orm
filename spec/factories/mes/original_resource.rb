FactoryGirl.define do
  factory :original_resource, class: 'Mes::OriginalResource' do
    uuid       { SecureRandom.uuid }
    content_id { "v-#{SecureRandom.base64}" }
    version    { 1 }
    period     { Mes::PeriodHelper.current }
    data do
      {
        'id'          => content_id,
        'asset_type'  => 'video',
        'version'     => version,
        'tenant_id'   => "t-#{SecureRandom.base64}",
        'status'      => 'READY',
        'language'    => 'en',
        'copyright'   => 'This is mine',
        'duration'    => 1111.11,
        'created_at'  => 1234234212,
        'modified_at' => created_at
      }
    end
  end
end
