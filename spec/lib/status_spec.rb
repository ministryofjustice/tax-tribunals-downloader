require 'spec_helper'

RSpec.describe TaxTribunal::Status do
  # These are to deal with the problem that the AWS::S3::Resource methods hook
  # before any of the RSPec stubs.
  # As a result AWS SDK classes are exceptionally difficult to stub, even using
  # AWS's own stubbing library.  At this time it, the AWS documentations does
  # not clearly explain how to stub ::Resource calls and the ::Client
  # examples shown all involve dependency injection of the stubbing classes.
  let(:bucket_status_good) {
    class BucketStatus
      def self.readable?
        true
      end
    end
  }

  let(:bucket_status_failed) {
    class BucketStatus
      def self.readable?
        false
      end
    end
  }

  let(:response) { JSON.parse(last_response.body, symbolize_names: true) }

  let(:objects) { double(:objects) }
  let(:first_key) { double(:first_key) }

  context 'everything is operating normally' do
    let(:authorize_url) { double(:authorize_url) }

    before do
      bucket_status_good
      allow(SecureRandom).to receive(:uuid).and_return('ABC123')
      allow(authorize_url).to receive(:authorize_url).and_return('https://some-url')
      allow(TaxTribunal::SsoClient).to receive(:new).and_return(authorize_url)
      get '/status'
    end

    describe 'service_status' do
      specify do
        expect(response[:service_status]).to eq('ok')
      end
    end

    describe 'read_test' do
      specify do
        expect(response[:dependencies][:s3][:read_test]).to eq('ok')
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
  end

  context 'the S3 read test failed' do
    before do
      bucket_status_failed
      get '/status'
    end

    describe 'service_status' do
      specify do
        expect(response[:service_status]).to eq('failed')
      end
    end

    describe 'read_test' do
      specify do
        expect(response[:dependencies][:s3][:read_test]).to eq('failed')
      end
    end
  end

  context 'the SSO test fails, returning blank' do
    before do
      bucket_status_good
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
      bucket_status_good
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
