require_relative 's3'

module TaxTribunal
  class File
    EXPIRES_IN = 3600 # seconds

    include TaxTribunal::S3

    attr_reader :key

    def initialize(key)
      @key = key
    end

    def s3_url
      obj.presigned_url(:get, expires_in: EXPIRES_IN)
    end

    def name
      key.partition('/').last
    end

    private

    def obj
      bucket.object(key)
    end
  end
end
