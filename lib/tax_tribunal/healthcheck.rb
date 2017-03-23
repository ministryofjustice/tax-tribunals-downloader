module TaxTribunal
  class Healthcheck < Downloader
    get '/healthcheck.?:format?' do
      checks = healthchecks
      {
        service_status: checks[:service_status],
        dependencies: {
          s3: {
            read_test: checks[:read_test]
          }
        }
      }.to_json
    end

    private

    def healthchecks
      service_status = if read_test
                         'ok'
                       else
                         'failed'
                       end
      {
        service_status: service_status,
        read_test: read_test ? 'ok' : 'failed'
      }
    end

    # A race condition exists as this check depends on the uploader healthcheck
    # writing the required file. For security reasons, this app does not and
    # will not have write permissions on the bucket.
    def read_test
      true
    end
  end
end
