require 'spec_helper'

RSpec.describe TaxTribunal::SsoClient do
  # The oauth client has a convoluted call chain that does not lend
  # itself well to mocking/stubbing.  The complexity of this spec is an
  # unfortunate reflection of this.
  let(:authorize_url) { double(:authorize_url) }
  let(:get_token) { double(:get_token) }
  let(:auth_code) { double(:auth_code, authorize_url: authorize_url, get_token: get_token) }
  let(:client) { instance_double(OAuth2::Client, auth_code: auth_code) }
  let(:session) { double(:session).as_null_object }

  describe 'OAuth2::Client' do
    let(:mojsso_id) { double(:id) }
    let(:mojsso_secret) { double(:secret) }
    let(:mojsso_url) { double(:url) }

    before do
      allow(OAuth2::Client).to receive(:new)
      # Need this generic hook for the `fetches MOJ...` ENV spies to work.
      allow(ENV).to receive(:fetch)
      # And these are specificaly for the `instantiates the client` spy.
      allow(ENV).to receive(:fetch).with('MOJSSO_ID').and_return(mojsso_id)
      allow(ENV).to receive(:fetch).with('MOJSSO_SECRET').and_return(mojsso_secret)
      allow(ENV).to receive(:fetch).with('MOJSSO_URL').and_return(mojsso_url)
      subject.send(:oauth_client)
    end

    it 'instantiates the client' do
      expect(OAuth2::Client).to have_received(:new).with(mojsso_id, mojsso_secret, site: mojsso_url)
    end

    it 'fetches MOJSSO_ID from ENV' do
      expect(ENV).to have_received(:fetch).with('MOJSSO_ID')
    end

    it 'fetches MOJSSO_SECRET from ENV' do
      expect(ENV).to have_received(:fetch).with('MOJSSO_SECRET')
    end

    it 'fetches MOJSSO_URL from ENV' do
      expect(ENV).to have_received(:fetch).with('MOJSSO_URL')
    end
  end

  context 'stubbed oauth client' do
    before do
      allow(subject).to receive(:oauth_client).and_return(client)
    end

    describe '#authorize_url' do
      before do
        allow(session).to receive(:values_at).with(:auth_key, :return_to).and_return([1234, 'http://test.com'])
        subject.authorize_url(session)
      end

      it 'builds the authorize_url' do
        expect(auth_code).to have_received(:authorize_url).
          with(redirect_uri: /http:\/\/localhost:3000.+auth_key=1234&return_to=http:\/\/test\.com/)
      end
    end

    describe '.authorize!' do
      let(:token_response_body) { double(:token_response_body).as_null_object }
      let(:token_response) { double(:token_response, body: token_response_body) }
      let(:parsed_response) { double(:parsed_response).as_null_object }

      before do
        allow(get_token).to receive(:get).and_return(token_response)
        allow(JSON).to receive(:parse).and_return(parsed_response)
        allow(subject).to receive(:authorized?).and_return(true)
        subject.authorize!(1234, 5678, 'http://test.com')
      end

      it 'builds the #get_token call' do
        expect(auth_code).to have_received(:get_token).with(
          1234,
          redirect_uri: /http:\/\/localhost:3000.+auth_key=5678&return_to=http:\/\/test\.com/
        )
      end

      it 'gets the token response' do
        expect(get_token).to have_received(:get).with('/api/user_details')
      end

      it 'parses the token response' do
        expect(JSON).to have_received(:parse).with(token_response_body, symbolize_names: true)
      end

      it 'checks if the user is authorized' do
        expect(subject).to have_received(:authorized?)
      end

      it 'uses the :permissions key from the response to check authorization' do
        expect(parsed_response).to have_received(:fetch).with(:permissions, {})
      end

      it 'returns the token response if the user is authorized' do
        expect(subject.authorize!(1234, 5678, 'http://test.com')).to eq(parsed_response)
      end

      it 'returns nil if the user is not authorized' do
        allow(subject).to receive(:authorized?).and_return(false)
        expect(subject.authorize!(1234, 5678, 'http://test.com')).to eq(nil)
      end
    end

    describe '.authorized?' do
      let(:permissions) { double(:permission).as_null_object }
      let(:organisation) { double(:organisation) }
      let(:roles) { double(:roles) }

      before do
        allow(permissions).to receive(:any?).and_yield(permissions)
        allow(permissions).to receive(:fetch).with(:organisation).and_return(organisation)
        allow(permissions).to receive(:fetch).with(:roles).and_return(roles)
        allow(organisation).to receive(:eql?).and_return(true)
        allow(roles).to receive(:include?).and_return(true)
        subject.authorized?(permissions)
      end

      it 'fetches organisation and roles from the response' do
        expect(permissions).to have_received(:fetch).with(:organisation)
        expect(permissions).to have_received(:fetch).with(:roles)
      end

      it 'checks that organization in the response is correct' do
        expect(organisation).to have_received(:eql?).with('hmcts.moj')
      end

      it 'checks that roles in the response are correct' do
        expect(roles).to have_received(:include?).with('viewer')
      end
    end
  end
end
