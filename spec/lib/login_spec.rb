require 'spec_helper'

RSpec.describe TaxTribunal::Login do
  let(:parsed_oauth_data) {
    {
      id: 1,
      email: "superadmin@example.com",
      first_name: "John",
      last_name: "Bloggs",
      permissions: [
        {
          organisation: "hmcts.moj",
          roles: ["viewer"]
        }
      ],
      links: {
        profile: "http://localhost:5000/profile",
        logout: "http://localhost:5000/users/sign_out"
      }
    }
  }

  describe '/login' do
    context 'the user is already logged in' do
      it 'shows the user that they are logged in' do
        get '/login', {}, 'rack.session' => { email: 'viewer@hmcts.gov.uk' }
        expect(last_response.body).to include('logged in')
      end
    end

    context 'the user is not already logged in' do
      it 'redirects to the oauth server so they can log in' do
        get '/login'
        follow_redirect!
        expect(last_request.url).
          to eq('http://localhost:5000/oauth/authorize?client_id=dummy+id&redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Foauth%2Fcallback&response_type=code')
      end
    end

    context 'logging' do
      let(:logger) { double(:logger) }

      it 'logs the request' do
        expect(logger).to receive(:info).with({ action: 'login', state: 'existing', message: 'viewer@hmcts.gov.uk' })
        expect_any_instance_of(Sinatra::Helpers).to receive(:logger).and_return(logger)
        get '/login', {}, 'rack.session' => { email: 'viewer@hmcts.gov.uk' }
      end
    end
  end

  describe '/logout' do
    let(:user_session) {
      {
        email: 'user@hmcts.gov.uk',
        logout: 'http://example.com/oauth'
      }
    }

    it 'shows the user a new login link' do
      get '/logout', {}, 'rack.session' => user_session
      expect(last_response.body).
        to include('Please log in from the specific case page.')
    end

    it 'clears the user session' do
      get '/logout', {}, 'rack.session' => user_session
      # Have to convert it to a vanilla hash because it is a
      # Rack::Session::Abstract::SessionHash and it != {}.
      expect(last_request.env['rack.session'].to_h).to eq({})
    end
  end

  describe '/oauth/callback' do
    before do
      allow_any_instance_of(TaxTribunal::Login).to receive(:oauth_response).and_return(parsed_oauth_data)
    end

    context 'authorised user' do
      it 'sets the session keys that indicate a login' do
        get 'oauth/callback?code=deadbeef'
        expect(last_request.env['rack.session'][:email]).to eq('superadmin@example.com')
        expect(last_request.env['rack.session'][:logout]).to eq('http://localhost:5000/users/sign_out')
        expect(last_request.env['rack.session'][:profile]).to eq('http://localhost:5000/profile')
      end

      it 'redirects to the requested url' do
        get 'oauth/callback?code=deadbeef', {}, { 'rack.session' => { return_to: 'http://example.org/1234' } }
        follow_redirect!
        expect(last_request.url).
          to eq('http://example.org/1234')
      end
    end

    context 'incorrect organisation' do
      before do
        allow_any_instance_of(TaxTribunal::Login).to receive(:oauth_response).and_return(
          parsed_oauth_data.merge(permissions: [{ organisation: 'noms', roles: ['viewer'] }])
        )
      end

      it 'does not set the session keys that indicate a login' do
        get 'oauth/callback?code=deadbeef'
        expect(last_request.env['rack.session'][:email]).to be_nil
        expect(last_request.env['rack.session'][:logout]).to be_nil
        expect(last_request.env['rack.session'][:profile]).to be_nil
      end
    end

    context 'incorrect role' do
      before do
        allow_any_instance_of(TaxTribunal::Login).to receive(:oauth_response).and_return(
          parsed_oauth_data.merge(
            permissions: [
              { organisation: 'hmcts.moj', roles: ['nobody'] }
            ]
          )
        )
      end

      it 'does not set the session keys that indicate a login' do
        get 'oauth/callback?code=deadbeef'
        expect(last_request.env['rack.session'][:email]).to be_nil
        expect(last_request.env['rack.session'][:logout]).to be_nil
        expect(last_request.env['rack.session'][:profile]).to be_nil
      end
    end

    context 'code not received' do
      it 'bounces the request to /logout' do
        get 'oauth/callback'
        follow_redirect!
        expect(last_request.url).
          to eq('http://example.org/logout')
      end
    end

    context 'logging' do
      let(:logger) { double(:logger) }

      it 'logs the request' do
        expect(logger).to receive(:info).once.with({ action: '/oauth/callback', status: 'success', message: parsed_oauth_data }.to_json)
        expect_any_instance_of(Sinatra::Helpers).to receive(:logger).and_return(logger)
        get 'oauth/callback?code=deadbeef'
      end
    end
  end

  context 'OAuth2::Client integration' do
    let(:client) { instance_double(OAuth2::Client) }
    let(:auth_code) { instance_double(OAuth2::Strategy::AuthCode) }
    let(:token) { instance_double(OAuth2::AccessToken) }
    let(:resp) { instance_double(OAuth2::Response) }

    before do
      expect(OAuth2::Client).to receive(:new).with(
        'dummy id',
        'dummy secret',
        site: 'http://localhost:5000'
      ).and_return(client)
      expect(client).to receive(:auth_code).and_return(auth_code)
      expect(auth_code).to receive(:get_token).with(
        'deadbeef',
        redirect_uri: 'http://localhost:3000/oauth/callback'
      ).and_return(token)
      expect(token).to receive(:get).with('/api/user_details').and_return(resp)
      # Returning a 'real' response here as CircleCI (and only CircleCI so
      # far) doesn't like the dummy response that was previously being used.
      expect(resp).to receive(:body).and_return(parsed_oauth_data.to_json)
    end

    it 'GETs the user details from the moj-sso server' do
      # Called indirectly as most of the interaction is buried in private
      # methods.
      get 'oauth/callback?code=deadbeef'
    end
  end

  context 'OAuth2::Client JSON response' do
    before do
      # Returning a 'real' response here as CircleCI (and only CircleCI so
      # far) doesn't like the dummy response that was previously being used.
      allow_any_instance_of(TaxTribunal::Login).to receive(:oauth_call).and_return(parsed_oauth_data.to_json)
    end

    it 'gets parsed' do
      expect(JSON).to receive(:parse).with(parsed_oauth_data.to_json, symbolize_names: true).and_return(parsed_oauth_data)
      # Called indirectly as most of the interaction is buried in private
      # methods.
      get 'oauth/callback?code=deadbeef'
    end
  end
end
