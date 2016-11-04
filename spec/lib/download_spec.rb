require 'spec_helper'

RSpec.describe TaxTribunal::Download do
  context 'logged in' do
    it 'shows files' do
      get '/12345', {}, { 'rack.session' => { email: 'user@hmcts.gov.uk' } }
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
