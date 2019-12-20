module TaxTribunal
  class File
    EXPIRES_IN = 300 # seconds

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
        expiry: expires_at
      ).to_s
    end

    def name
      key.partition('/').last
    end

    private

    def expires_at
      EXPIRES_IN ? (Time.now + EXPIRES_IN).utc.iso8601 : nil
    end
  end
end
