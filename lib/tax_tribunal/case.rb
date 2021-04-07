module TaxTribunal
  class Case
    # rubocop:disable  Style/RedundantRegexpEscape
    DIRECTORY = %r{\/$}.freeze
    # rubocop:enable  Style/RedundantRegexpEscape

    class CaseNotFound < StandardError; end
    include TaxTribunal::AzureBlobStorage

    attr_reader :case_id

    def initialize(case_id)
      @case_id = case_id
    end

    def files
      @files ||= storage.list_blobs(files_container_name, prefix: case_id)
                        .map(&:name)
                        .reject { |o| o.match(DIRECTORY) }
                        .map do |o|
        o = o.gsub(' ', '%20')
        File.new(o)
      end
    end
  end
end
