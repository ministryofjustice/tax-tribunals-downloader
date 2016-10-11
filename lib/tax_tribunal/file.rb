require_relative 's3'

module TaxTribunal
  class File
    EXPIRES_IN = 60

    include TaxTribunal::S3

    attr_reader :key

    def initialize(key)
      @key = key
    end

    def s3_url
      obj.presigned_url(:get, expires_in: EXPIRES_IN)
    end

    private

    def obj
      bucket.object(key)
    end
  end
end
