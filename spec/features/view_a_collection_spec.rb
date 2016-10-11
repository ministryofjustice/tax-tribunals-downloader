require 'spec_helper'

# These are named/laid-out like unit tests to ensure that mutant uses them
# efficiently when it is killing mutations.
RSpec.feature TaxTribunal::Downloader do
  # Sinatra was including the spec expectations in its stack trace. This was
  # causing the expectations to pass when sinatra showed the standard
  # formatted error message. Memoizing them here keeps that from happening.
  let(:case_1) { '12345' }
  let(:case_2) { '23456' }

  before do
    visit '12345'
  end

  describe '#show' do
    it 'links to the cases' do
      expect(page).to have_text("Files for #{case_1}")
      expect(page).to have_text('testfile.docx')
    end

    it 'links to the files using s3 tokenzied links with short expiry times' do
      expect(page).to have_link(
        'testfile.docx',
        href: %r{tax-tribs-doc-upload-test.+amazonaws.+\/12345\/testfile.docx.+X-Amz-Credential.+X-Amz-Expires=60.+X-Amz-Signature}
      )
    end
  end
end
