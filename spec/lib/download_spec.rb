require 'spec_helper'

RSpec.describe TaxTribunal::Download do
  # This ensures the record exists on the S3 test bucket if you need to re-record the cassette.
  before do
    TaxTribunal::User.create('abc123', email: 'bob@example.com', profile: 'http://sso-profile-link', logout: 'http://sso-logout-link')
  end

  context 'logged in' do
    it 'shows files' do
      get '/12345', {}, { 'rack.session' => { auth_key: 'abc123' } }
      expect(last_response.body).to include('Files for 12345')
    end
  end

  context 'not logged in' do
    it 'show the user a login link' do
      get '/12345'
      expect(last_response.body).to include("<a href='/login'>Login</a>")
    end
  end
end
