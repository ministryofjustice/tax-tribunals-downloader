module TaxTribunal
  class ContainerStatus
    extend TaxTribunal::AzureBlobStorage

    def self.readable?
      storage.list_blobs(files_container_name).is_a?(Array)
    end
  end
end
