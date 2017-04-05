require 'spec_helper'

RSpec.describe TaxTribunal::Login do
  let(:logger) { double(:logger).as_null_object }
  let(:user) { double(:user).as_null_object }
  let(:session) { double(:session).as_null_object }
  let(:sso_client) { double(:sso_client).as_null_object }

  before do
    allow_any_instance_of(described_class).to receive(:logger).and_return(logger)
  end

  describe 'get /login' do
    before do
      allow_any_instance_of(described_class).to receive(:current_user).and_return(user)
    end

    context 'logged in' do
      before do
        allow_any_instance_of(described_class).to receive(:logged_in?).and_return(true)
        get '/login'
      end

      it 'renders the :root template' do
        expect(last_response.body).to include('<h2 class="heading-medium">Please log in from the specific case page.</h2>')
      end

      it 'logs the request' do
        expect(logger).to have_received(:info)
      end
    end

    context 'not logged in' do
      before do
        allow_any_instance_of(described_class).to receive(:logged_in?).and_return(false)
        allow(SecureRandom).to receive(:uuid).and_return(12345)
        allow_any_instance_of(described_class).to receive(:session).and_return(session)
        allow(TaxTribunal::SsoClient).to receive(:new).and_return(sso_client)
        get '/login'
      end

      it 'logs the request' do
        expect(logger).to have_received(:info)
      end

      it 'stores an auth_key in the session to lookup on callback' do
        expect(session).to have_received(:'[]=').with(:auth_key, 12345).at_least(:once)
      end

      context 'builds and redirects to oauth authorized callback url' do
        it 'builds the authorized callback url' do
          expect(sso_client).to have_received(:authorize_url).with(session)
        end

        it 'redirects to the authorized callback url' do
          expect_any_instance_of(described_class).to receive(:redirect).with(sso_client)
          get '/login'
        end
      end
    end
  end

  describe 'get /logout' do
    context 'logged in' do
      before do
        allow_any_instance_of(described_class).to receive(:current_user).and_return(user)
        allow_any_instance_of(described_class).to receive(:logged_in?).and_return(true)
        get '/logout'
      end

      it 'logs the request' do
        expect(logger).to have_received(:info)
      end
    end

    it 'destroies the session' do
      allow_any_instance_of(described_class).to receive(:session).and_return(session)
      expect(session).to receive(:destroy)
      get '/logout'
    end

    it 'renders the :root template' do
      get '/logout'
      expect(last_response.body).to include('<h2 class="heading-medium">Please log in from the specific case page.</h2>')
    end
  end

  describe 'get /oauth/callback' do
    subject { get '/oauth/callback', params }
    let(:auth_key) { 67890 }
    let(:params) { { code: 12345, auth_key: auth_key, return_to: 'some-url' } }
    let(:json_response) { double(:json_response).as_null_object }

    before do
      allow(TaxTribunal::User).to receive(:create).and_return(double(:user))
      allow(TaxTribunal::User).to receive(:find).and_return(nil)
      allow(TaxTribunal::SsoClient).to receive(:new).and_return(sso_client)
    end

    it 'returns 422 without the code parameter' do
      params.delete(:code)
      subject
      expect(last_response.status).to be(422)
    end

    it 'returns 422 without the auth_key parameter' do
      params.delete(:auth_key)
      subject
      expect(last_response.status).to be(422)
    end

    it 'returns 422 without the return_to parameter' do
      params.delete(:return_to)
      subject
      expect(last_response.status).to be(422)
    end

    context 'user is already persisted' do
      before do
        allow(TaxTribunal::User).to receive(:find).and_return(user)
        subject
      end

      it 'logs the request' do
        expect(logger).to have_received(:info).with(hash_including(user_found: user))
      end
    end

    describe '.log_result' do
      before do
        allow(sso_client).to receive(:authorize!).and_return(json_response)
      end

      it 'checks the response for an error key' do
        allow(json_response).to receive(:key?).and_return(false)
        expect(json_response).to receive(:fetch).with(:error, nil)
        subject
      end

      it 'sets error level if the params contain an :error key' do
        allow(json_response).to receive(:key?).and_return(false)
        expect(logger).to receive(:error).with(json_response)
        subject
      end

      it 'sets level info if the params do not contain an :error key' do
        expect(logger).to receive(:info)
        subject
      end
    end
  end
end
