require_relative 's3'

module TaxTribunal
  class Case
    DIRECTORY = %r{\/$}

    class CaseNotFound < StandardError; end
    include TaxTribunal::S3
    extend Forwardable
    def_delegators :bucket, :objects

    attr_reader :case_id

    def initialize(case_id)
      @case_id = case_id
    end

    def exists?
      !files.empty?
    end

    def files
      @files ||= objects(prefix: case_id).
        map(&:key).
        reject { |o| o.match(DIRECTORY) }.
        map { |o|
          File.new(o)
        }
    end
  end
end
