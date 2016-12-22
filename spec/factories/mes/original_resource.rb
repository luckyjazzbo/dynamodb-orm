# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :original_resource, class: 'Mes::OriginalResource' do
    uuid       { SecureRandom.uuid }
    content_id { "v-#{SecureRandom.base64}" }
    version    { 1 }
    found      { true }
    period     { Mes::PeriodHelper.current }
    data do
      {
        'id'          => content_id,
        'source_id'   => '269557',
        'asset_type'  => 'video',
        'version'     => version,
        'tenant_id'   => "t-#{SecureRandom.base64}",
        'language'    => 'en',
        'copyright'   => 'This is mine',
        'duration'    => 1111.11,
        'created_at'  => 1234234212,
        'modified_at' => 1234234222,
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
        'internal_status'  => '',
        'is_locked' => false,
        'start_date_absolute' => 1469690634,
        'end_date_absolute'   => 1469691634,
        'geo_locations'       => [],
        'keywords' => [
          "Abenteuet Auto",
          "BMW 325 ti Compact",
          "VW Golf V6 4 Motion",
          "Video"
        ]
      }
    end

    children_data do
      {
        'images' => [
          {
            'id' => 'i-321',
            'url' => 'http://url',
            'url_encrypted' => 'http://url/encrypted'
          }
        ],

        'taxonomies' => [
          {
            'id' => 'tx-123',
            'parent_id' => 'p-go',
            'title' => {
              'de' => 'Say what again I dare you',
              'en' => 'Say what again I dare you'
            },
            'type_id' => 'ty-yippie-ki-yay',
            'image' => 'im-die'
          }
        ],

        'ad_profiles' => [
          {
            'ad_groups' => [
              {
                'geolocation' => 'en',
                'sales_house' => 't-tratatatata',
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
