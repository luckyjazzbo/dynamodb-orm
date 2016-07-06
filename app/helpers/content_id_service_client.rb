module Mes
  class ContentIdServiceClient
    REQUEST_PATH = '/v1/next_ids/%s/1'.freeze

    attr_reader :request_url

    def initialize(content_id_service_url, asset_type)
      @request_url = File.join content_id_service_url, REQUEST_PATH % asset_type
    end

    def next_id
      first_returned_id Faraday.get(request_url).body
    end

    private

    def first_returned_id(response)
      data = JSON.parse(response)
      data['ids'][0]
    end
  end
end
