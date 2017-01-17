require 'spec_helper'

# These are named/laid-out like unit tests to ensure that mutant uses them
# efficiently when it is killing mutations.
RSpec.describe TaxTribunal::Download do
  # This ensures the record exists on the S3 test bucket if you need to re-record the cassette.
  before do
    TaxTribunal::User.create('abc123', email: 'bob@example.com', profile: 'http://sso-profile-link', logout: 'http://sso-logout-link')
  end

	# Sinatra was including the spec expectations in its stack trace. This was
	# causing the expectations to pass when sinatra showed the standard
	# formatted error message. Memoizing them here keeps that from happening.
	let(:case_1) { '12345' }
	let(:case_2) { '23456' }

	before do
    get '12345', {}, { 'rack.session' => { auth_key: 'abc123' } }
	end

	describe '#show' do
		it 'links to the cases' do
      expect(last_response.body).to include('Appeal or application documents')
      expect(last_response.body).to include('testfile.docx')
		end

		it 'links to the files using s3 tokenzied links with short expiry times' do
      expect(last_response.body).to match(
				%r{tax-tribs-doc-upload-test.+amazonaws.+\/12345\/testfile.docx.+X-Amz-Credential.+X-Amz-Expires=60.+X-Amz-Signature}
			)
		end
	end
end
