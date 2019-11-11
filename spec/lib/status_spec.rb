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
      allow_any_instance_of(described_class).to receive(:`).with('git rev-parse HEAD').and_return('ABC123')
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
      # Necessary evil for coverage purposes.
      it 'calls `git rev-parse HEAD`' do
        version_string = double
        # Mutant kill
        expect(version_string).to receive(:chomp)
        expect_any_instance_of(described_class).to receive(:`).with('git rev-parse HEAD').and_return(version_string)
        get '/status'
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
