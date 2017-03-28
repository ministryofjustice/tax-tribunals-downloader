require 'spec_helper'

RSpec.describe TaxTribunal::Login do
  let(:logger) { double.as_null_object }
  let(:user) { double.as_null_object }
  let(:session) { double.as_null_object }

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
      end

      it 'renders the :root template' do
        get '/login'
        expect(last_response.body).to include('<h2 class="heading-medium">Please log in from the specific case page.</h2>')
      end

      it 'logs the request' do
        expect(logger).to receive(:info)
        get '/login'
      end
    end

    context 'not logged in' do
      before do
        allow_any_instance_of(described_class).to receive(:logged_in?).and_return(false)
        allow(SecureRandom).to receive(:uuid).and_return(12345)
        allow_any_instance_of(described_class).to receive(:session).and_return(session)
      end

      it 'logs the request' do
        expect(logger).to receive(:info)
        get '/login'
      end

      it 'stores an auth_key in the session to lookup on callback' do
        allow_any_instance_of(described_class).to receive(:session).and_return(session)
        expect(session).to receive(:'[]=').with(:auth_key, 12345).at_least(:once)
        get '/login'
      end

      context 'builds and redirects to oauth authorized callback url' do
        let(:auth_code) { double }
        let(:auth_key) { 12345 }
        let(:return_to) { 'http://this-host-callback-url' }
        let(:authorized_callback_url) { 'http://oauth-service-authorized-url' }
        let(:redirect_uri) { "#{described_class::CALLBACK_URI}?auth_key=#{auth_key}&return_to=#{return_to}" }

        before do
          allow_any_instance_of(described_class).to receive(:oauth_client).and_return(double(auth_code: auth_code))
          allow(session).to receive(:'[]').with(:auth_key).and_return(auth_key)
          allow(session).to receive(:'[]').with(:return_to).and_return(return_to)
        end

        it 'builds the authorized callback url' do
          expect(auth_code).to receive(:authorize_url).with(redirect_uri: redirect_uri)
          get '/login'
        end

        it 'redirects to the authorized callback url' do
          allow(auth_code).to receive(:authorize_url).and_return(authorized_callback_url)
          expect_any_instance_of(described_class).to receive(:redirect).with(authorized_callback_url)
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
      end

      it 'logs the request' do
        expect(logger).to receive(:info)
        get '/logout'
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
    let(:get_token) { double(:get_token).as_null_object }
    let(:auth_code) { double(:auth_code, get_token: get_token) }
    let(:oauth_client) { double(:oauth_client, auth_code: auth_code) }
    let(:json_response) { double(:json_response).as_null_object }

    before do
      allow_any_instance_of(described_class).to receive(:oauth_client).and_return(oauth_client)
      allow(JSON).to receive(:parse).and_return(json_response)
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


    # The oauth client has a convoluted call chain that does not lend
    # itself well to mocking/stubbing.  The complexity of this spec is an
    # unfortunate reflection of this.
    describe '.authorize!' do
      let(:permissions) { double(:permission).as_null_object }
      let(:organisation) { double(:organisation).as_null_object }
      let(:role) { double(:role).as_null_object }

      before do
        # Fall through so we hit `.authorize!`, which is a private method.
        allow(TaxTribunal::User).to receive(:find).and_return(nil)
        allow(json_response).to receive(:fetch).and_return(permissions)
        allow(permissions).to receive(:fetch).with(:organisation).and_return(organisation)
        allow(permissions).to receive(:fetch).with(:roles).and_return(role)
        # Default for the spec is to authorise the user.  This is explicity
        # tested in the `.authorised?` context, below.
        allow(organisation).to receive(:eql?).and_return(true)
        allow(role).to receive(:include?).and_return(true)
      end

      describe '.log_result' do
        it 'sets error level if the params contain an :error key' do
          allow(json_response).to receive(:key?).and_return(false)
          expect(json_response).to receive(:fetch).with(:error, nil).and_return(json_response)
          expect(logger).to receive(:error).with(json_response)
          subject
        end

        it 'sets level if the params do not contain an :error key' do
          allow(json_response).to receive(:key?).and_return(false)
          expect(json_response).to receive(:fetch).with(:error, nil).and_return(nil)
          expect(logger).to receive(:info).with(json_response)
          subject
        end
      end

      context 'missing email or link keys' do
        specify ':email key is missing from the request parameters' do
          expect(json_response).to receive(:key?).with(:email).and_return(false)
          expect(logger).to receive(:error)
          subject
        end

        specify ':links key is missing from the requiest parameters' do
          expect(json_response).to receive(:key?).with(:links).and_return(false)
          expect(logger).to receive(:error)
          subject
        end
      end

      it 'fetches pemissions from the response body' do
        expect(json_response).to receive(:fetch).with(:permissions, {})
        # Keep it from fallling through to User.create
        allow(json_response).to receive(:key?).and_return(false)
        subject
      end

      describe '.authorised?' do
        before do
          # Without this, permissions bypasses the #any? block check.
          expect(permissions).to receive(:any?).and_yield(permissions)
          # Prevent it from falling through the the Aws::S3 client.
          allow(json_response).to receive(:key?).and_return(false)
        end

        it 'checks the organisation received from moj-sso' do
          expect(organisation).to receive(:eql?).with(described_class::ORG)
          subject
        end

        it 'checks the role received from moj-sso' do
          expect(role).to receive(:include?).with(described_class::ROLE)
          subject
        end
      end
    end

    context 'user info is persisted already' do
      let(:user) { double(email: 'test@test.com') }

      before do
        allow(TaxTribunal::User).to receive(:find).with(auth_key.to_s).and_return(user)
      end

      it 'gets the user info using User#find' do
        expect(TaxTribunal::User).to receive(:find).with(auth_key.to_s).and_return(user)
        subject
      end

      it 'logs the request' do
        expect(logger).to receive(:info)
        subject
      end

      it 'redirects to the return_to param' do
        expect_any_instance_of(described_class).to receive(:redirect).with(/#{params[:return_to]}/)
        subject
      end
    end
  end
end
