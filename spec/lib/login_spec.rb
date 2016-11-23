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

  # This ensures the record exists on the S3 test bucket if you need to re-record the cassette.
  before do
    TaxTribunal::User.create('56789', email: 'bob@example.com', profile: 'http://sso-profile-link', logout: 'http://sso-logout-link')

    # No need to hit S3 for this now.  These are overriden in individual specs as needed.
    allow(TaxTribunal::User).to receive(:find)
    allow(TaxTribunal::User).to receive(:create)
  end

  describe '/login' do
    context 'the user is already logged in' do
      before do
        allow(TaxTribunal::User).to receive(:find).and_return(OpenStruct.new(email: 'bob@example.com'))
      end

      it 'shows the user that they are logged in' do
        get '/login', {}, 'rack.session' => { auth_key: '56789' }
        expect(last_response.body).to include('log in from the specific case page')
      end

      context 'logging' do
        let(:logger) { double(:logger) }

        it 'logs the request' do
          expect(logger).to receive(:info).with({ action: 'login', state: 'existing', message: 'bob@example.com' })
          expect_any_instance_of(Sinatra::Helpers).to receive(:logger).and_return(logger)
          get '/login', {}, 'rack.session' => { auth_key: '56789' }
        end
      end
    end

    context 'the user is not already logged in' do
      before do
        allow(SecureRandom).to receive(:uuid).and_return(12345)
      end

      it 'redirects to the oauth server so they can log in' do
        get '/login'
        follow_redirect!
        expect(last_request.url).
          to eq("http://localhost:5000/oauth/authorize?client_id=dummy+id&redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Foauth%2Fcallback%3Fauth_key%3D12345%26return_to%3D&response_type=code")
      end
    end

  end

  describe '/logout' do
    before do
      get '/logout', {}, 'rack.session' => { auth_key: '56789' }
    end

    it 'shows the user a new login link' do
      expect(last_response.body).
        to include('Please log in from the specific case page.')
    end

    it 'clears the user session' do
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
      it 'persists the auth token and email to an s3 bucket to indicate a login' do
        expect(TaxTribunal::User).
          to receive(:create).
          with('45678',
               { email: 'superadmin@example.com',
                 logout: 'http://localhost:5000/users/sign_out',
                 profile: 'http://localhost:5000/profile' })
          get 'oauth/callback?code=deadbeef&auth_key=45678&return_to=/12345'
      end

      it 'redirects to the requested page' do
        get 'oauth/callback?code=deadbeef&auth_key=45678&return_to=/12345'
        expect(last_response.status).to eq(302)
        expect(last_request.url).to eq("http://example.org/oauth/callback?code=deadbeef&auth_key=45678&return_to=%2F12345")
      end

    end

    context 'email missing' do
      before do
        allow_any_instance_of(TaxTribunal::Login).to receive(:oauth_response).and_return(
          parsed_oauth_data.merge(email: nil)
        )
      end

      it 'does not persist the auth token' do
        expect(TaxTribunal::User).not_to receive(:create)
        get 'oauth/callback?code=deadbeef&auth_key=45678&return_to=/12345'
      end
    end

    context 'incorrect organisation' do
      before do
        allow_any_instance_of(TaxTribunal::Login).to receive(:oauth_response).and_return(
          parsed_oauth_data.merge(permissions: [{ organisation: 'noms', roles: ['viewer'] }])
        )
      end

      it 'does not persist the auth token' do
        expect(TaxTribunal::User).not_to receive(:create)
        get 'oauth/callback?code=deadbeef&auth_key=45678&return_to=/12345'
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

      it 'does not persist the auth token' do
        expect(TaxTribunal::User).not_to receive(:create)
        get 'oauth/callback?code=deadbeef&auth_key=45678&return_to=/12345'
      end
    end

    context 'code not received' do
      it 'repsonds with a 422' do
        get 'oauth/callback?auth_key=45678&return_to=/12345'
        expect(last_response.status).to eq(422)
      end
    end

    describe 'logging' do
      let(:logger) { double(:logger) }

      context 'authenticated user' do
        before do
          allow(TaxTribunal::User).to receive(:find).and_return(OpenStruct.new(email: 'superadmin@example.com'))
        end

        it 'logs the request' do
          expect(logger).to receive(:info).with(
            {
              action: '/oauth/callback',
              message: 'already persisted superadmin@example.com to 45678',
              requested: '/12345'
            }.to_json
          )
          expect_any_instance_of(Sinatra::Helpers).to receive(:logger).and_return(logger)
          get 'oauth/callback?code=deadbeef&auth_key=45678&return_to=/12345'
        end
      end

      context 'new log in' do
        before do
          allow(TaxTribunal::User).to receive(:find).and_return(nil)
          allow_any_instance_of(TaxTribunal::Login).to receive(:oauth_response).and_return(parsed_oauth_data)
        end

        it 'logs the request' do
          expect(logger).to receive(:info).with(
            {
              action: '/oauth/callback',
              message: 'persisted superadmin@example.com to 45678',
              requested: '/12345'
            }.to_json
          )
          expect_any_instance_of(Sinatra::Helpers).to receive(:logger).and_return(logger)
          get 'oauth/callback?code=deadbeef&auth_key=45678&return_to=/12345'
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

        it 'logs the request' do
          expect(logger).to receive(:info).with(
            {
              action: '/oauth/callback',
              method: 'persist_user!',
              status: 'failed',
              message: {}
            }.to_json
          )
          expect_any_instance_of(Sinatra::Helpers).to receive(:logger).and_return(logger)
          get 'oauth/callback?code=deadbeef&auth_key=45678&return_to=/12345'
        end
      end
    end
  end
end
