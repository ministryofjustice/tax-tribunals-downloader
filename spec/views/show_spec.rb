require 'spec_helper'
require 'erubis'

RSpec.describe 'show template' do
  let(:tribunal_case) { double(files: [file]) }
  let(:template_file) { File.read("#{File.dirname(__FILE__)}/../../views/show.erubis") }
  subject { Erubis::Eruby.new(template_file) }

  describe 'escapes html in filenames' do
    let(:file) { double(file_name: 'test.doc', url: 'https://example.blob.core.windows.net', name: '<script>alert("boom!");</script>') }

    specify do
      expect(subject.evaluate(case: tribunal_case)).not_to match(/<script>alert\("boom!"\);<\/script>/)
    end
  end
end
