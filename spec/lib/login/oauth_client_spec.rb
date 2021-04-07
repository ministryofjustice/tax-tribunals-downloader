require 'spec_helper'

RSpec.describe TaxTribunal::Login do
  let(:parsed_oauth_data) do
    {
      id: 1,
      email: 'superadmin@example.com',
      first_name: 'John',
      last_name: 'Bloggs',
      permissions: [
        {
          organisation: 'hmcts.moj',
          roles: ['viewer']
        }
      ],
      links: {
        profile: 'http://localhost:5000/profile',
        logout: 'http://localhost:5000/users/sign_out'
      }
    }
  end

  before do
    # No need to hit Blob Storage for this now.
    allow(TaxTribunal::User).to receive(:find)
    allow(TaxTribunal::User).to receive(:create)
  end

  context 'OAuth2::Client integration' do
    let(:client) { instance_double(OAuth2::Client) }
    let(:auth_code) { instance_double(OAuth2::Strategy::AuthCode) }
    let(:token) { instance_double(OAuth2::AccessToken) }
    let(:resp) { instance_double(OAuth2::Response) }

    before do
      expect(OAuth2::Client).to receive(:new).with(
        instance_of(String),
        instance_of(String),
        site: instance_of(String)
      ).and_return(client)
      expect(client).to receive(:auth_code).and_return(auth_code)
      expect(auth_code).to receive(:get_token).with(
        instance_of(String),
        redirect_uri: 'http://localhost:3000/oauth/callback?auth_key=45678&return_to=/12345'
      ).and_return(token)
      expect(token).to receive(:get).with('/api/user_details').and_return(resp)
    end

    it 'GETs the user details from the moj-sso server' do
      # Returning a 'real' response here as CircleCI (and only CircleCI so
      # far) doesn't like the dummy response that was previously being used.
      expect(resp).to receive(:body).and_return(parsed_oauth_data.to_json)
      # Called indirectly as most of the interaction is buried in private
      # methods.
      get 'oauth/callback?code=deadbeef&auth_key=45678&return_to=/12345'
    end

    context 'OAuth2::Client JSON response' do
      it 'gets parsed' do
        allow(resp).to receive(:body).and_return(parsed_oauth_data.to_json)
        expect(JSON).to receive(:parse).with(parsed_oauth_data.to_json,
                                             symbolize_names: true).and_return(parsed_oauth_data)
        # Called indirectly as most of the interaction is buried in private
        # methods.
        get 'oauth/callback?code=deadbeef&auth_key=45678&return_to=/12345'
      end
    end
  end
end
