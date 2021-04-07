module TaxTribunal
  module AzureBlobStorage
    def storage
      Azure::Storage::Blob::BlobService.create
    end

    def signer
      Azure::Storage::Common::Core::Auth::SharedAccessSignature.new
    end

    private

    def user_container_name
      ENV.fetch('USER_CONTAINER_NAME')
    end

    def files_container_name
      ENV.fetch('FILES_CONTAINER_NAME')
    end
  end
end
