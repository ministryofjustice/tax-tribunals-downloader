require 'aws-sdk'

module TaxTribunal
  module S3
    def s3
      Aws::S3::Resource.new(region: ENV.fetch('AWS_REGION', 'eu-west-1'))
    end

    def bucket
      s3.bucket(bucket_name)
    end

    def bucket_name
      ENV.fetch('BUCKET_NAME')
    end
  end
end
