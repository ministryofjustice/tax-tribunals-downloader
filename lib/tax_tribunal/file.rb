module TaxTribunal
  class File
    EXPIRES_IN = 3600 # seconds

    include TaxTribunal::AzureBlobStorage

    attr_reader :key

    def initialize(key)
      @key = key
    end

    def url
      file_uri = storage.generate_uri("#{files_container_name}/#{key}")

      signer.signed_uri(
        file_uri,
        false,
        service: 'b',
        permissions: 'r',
        content_disposition: :attachment,
        expiry: expire_in
      ).to_s
    end

    def name
      key.partition('/').last
    end

    private

    def expire_in
      EXPIRES_IN ? (Time.now + EXPIRES_IN).utc.iso8601 : nil
    end
  end
end
