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
        'language'    => 'en',
        'copyright'   => 'This is mine',
        'duration'    => 1111.11,
        'created_at'  => 1234234212,
        'modified_at' => created_at,
        'title' => {
          'en' => 'Awesome video',
          'de' => 'Großartiges Video'
        },
        'description' => {
          'en' => 'You gonna watch this again',
          'de' => 'Sie beobachten werde auch in diesem'
        },
        'age_ratings' => {
          'FSK'  => 'FSK12',
          'CARA' => 'PG13'
        },
        'start_date_absolute' => '2016-07-28 10:23:54+00',
        'end_date_absolute'   => '2016-07-28 10:23:54+00',
        'status'              => 'READY'
      }
    end

    children_data do
      {
        'images' => [
          { 'id' => 'i-321', 'url' => 'http://url' }
        ],

        'taxonomies' => [
          { 'id' => 'tx-123' }
        ],

        'ad_profiles' => [
          {
            'ad_groups' => [
              {
                'geolocation' => 'en',
                'sales_house_id' => 't-tratatatata',
                'reach_measured' => { 'postrolls' => ['begin-[__VIDEOID__]-end'] }
              }
            ]
          }
        ],

        'license_profiles' => [
          {
            'asset_type'          => 'license_profile',
            'type'                => 'SYNDICATION',
            'id'                  => 'l-3d92dh9283hd23',
            'tenant_id'           => 't-123113233',
            'name'                => 'my cool License Profile for GNTM',
            'name_short'          => 'myrule',
            'start_date'          => 1352345234,
            'end_date'            => 1352345234,
            'products'            => ['FIXED_PRICE', 'ADS'],
            'sales_houses'        => ['t-123113233'],
            'geo_locations'       => ['DE', 'AT'],
            'device_classes'      => ['BROWSER', 'MOBILE', 'SETTOPBOX', 'SMARTTV', 'HBBTV', 'GAMECONSOLE', 'HDMISTICK'],
            'bandwidth_max'       => { 'BROWSER' => 400, 'MOBILE' => 100 },
            'publisher_whitelist' => ['t-w123efwe', 't-asde345ad'],
            'publisher_blacklist' => ['t-ef23f23f', 't-ef23f232'],
            'max_resolution'      => 'SD',
            'drm'                 => false,
            'entitlement'         => false,
            'created_at'          => 123123123,
            'modified_at'         => 1234234212,
            'version'             => 2,
            'status'              => 'READY',
            'player_logo'         => 'i-1234'
          }
        ]
      }
    end
  end
end
