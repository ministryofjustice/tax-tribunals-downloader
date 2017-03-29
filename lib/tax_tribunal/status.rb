# :nocov:
class BucketStatus
  include TaxTribunal::S3
  extend Forwardable
  def_delegators :bucket, :objects

  def readable?
    new.objects.first.exists?
  end
end
# :nocov:

module TaxTribunal
  class Status < Downloader

    get '/status.?:format?' do
      checks = service_status
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

    def service_status
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

    def read_test
      BucketStatus.readable?
    end
  end
end
