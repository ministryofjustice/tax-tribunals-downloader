module TaxTribunal
  class BucketStatus
    include TaxTribunal::S3
    extend Forwardable
    def_delegators :bucket, :objects

    def self.readable?
      new.objects.first.exists?
    end
  end
end
