require 'spec_helper'

RSpec.describe TaxTribunal::Status do
  let(:container_status) { class_double(TaxTribunal::ContainerStatus) }

  before do
    TaxTribunal::Downloader.set :container_status, container_status
    allow(container_status).to receive(:readable?).and_return(true)
  end

  let(:response) { JSON.parse(last_response.body, symbolize_names: true) }

  let(:objects) { double(:objects) }
  let(:first_key) { double(:first_key) }

  context 'everything is operating normally' do
    let(:authorize_url) { double(:authorize_url) }

    before do
      allow(SecureRandom).to receive(:uuid).and_return('ABC123')
      allow(authorize_url).to receive(:authorize_url).and_return('https://some-url')
      allow(TaxTribunal::SsoClient).to receive(:new).and_return(authorize_url)
      allow(ENV).to receive(:[]).with('APP_VERSION').and_return('c6f1b2a')
      get '/status'
    end

    describe 'service_status' do
      specify do
        expect(response[:service_status]).to eq('ok')
      end
    end

    describe 'read_test' do
      specify do
        expect(response[:dependencies][:blob_storage][:read_test]).to eq('ok')
      end
    end

    describe 'sso_test' do
      specify do
        expect(response[:dependencies][:sso_test]).to eq('ok')
      end

      # Mutant kill
      specify 'ensure the test makes realistic authorize_url call' do
        expect(authorize_url).to have_received(:authorize_url).with(auth_key: 'ABC123', return_to: '/')
      end
    end

    describe 'version' do
      let(:resp) { JSON.parse(last_response.body, symbolize_names: true) }

      it 'displays the APP_VERSION env var' do
        get '/status'
        expect(resp).to include(version: 'c6f1b2a')
      end
    end
  end

  context 'the blob storage read test failed' do
    before do
      allow(container_status).to receive(:readable?).and_return(false)
      get '/status'
    end

    describe 'service_status' do
      specify do
        expect(response[:service_status]).to eq('failed')
      end
    end

    describe 'read_test' do
      specify do
        expect(response[:dependencies][:blob_storage][:read_test]).to eq('failed')
      end
    end
  end

  context 'the SSO test fails, returning blank' do
    before do
      allow(TaxTribunal::SsoClient).to receive(:new).and_return(double(authorize_url: ''))
      get '/status'
    end

    describe 'service_status' do
      specify do
        expect(response[:service_status]).to eq('failed')
      end
    end

    describe 'sso_test' do
      specify do
        expect(response[:dependencies][:sso_test]).to eq('failed')
      end
    end
  end

  context 'the SSO test fails, raising an exception' do
    before do
      allow(TaxTribunal::SsoClient).to receive(:new).and_raise(RuntimeError)
      get '/status'
    end

    describe 'service_status' do
      specify do
        expect(response[:service_status]).to eq('failed')
      end
    end

    describe 'sso_test' do
      specify do
        expect(response[:dependencies][:sso_test]).to eq('failed')
      end
    end
  end
end
