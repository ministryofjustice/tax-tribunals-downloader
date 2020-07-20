module TaxTribunal
  class Case
    DIRECTORY = %r{\/$}

    class CaseNotFound < StandardError; end
    include TaxTribunal::AzureBlobStorage

    attr_reader :case_id

    def initialize(case_id)
      @case_id = case_id
    end

    def files
      @files ||= storage.list_blobs(files_container_name, prefix: case_id).
      map(&:name).
      reject { |o| o.match(DIRECTORY) }.
      map { |o|
        File.new(o)
      }
    end
  end
end
