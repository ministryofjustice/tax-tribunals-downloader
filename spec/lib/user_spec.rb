require 'spec_helper'

RSpec.describe TaxTribunal::User do
  subject { described_class }
  let(:bucket) { double(:bucket) }

  before do
    allow(described_class).to receive(:bucket).and_return(bucket)
    allow(ENV).to receive(:fetch).at_least(:once)
  end

  it 'uses the USER_BUCKET ENV variable for persistence' do
    subject.bucket_name
    expect(ENV).to have_received(:fetch).with('USER_BUCKET_NAME')
  end

  describe '.find' do
    let(:parsed_json) { double(:parsed_json).as_null_object }

    before do
      allow(JSON).to receive(:parse).and_return(parsed_json)
      allow(OpenStruct).to receive(:new)
    end

    it 'returns nil if it is called with nil' do
      expect(subject.find(nil)).to be_nil
    end

    it 'returns nil if it is called with an empty string' do
      expect(subject.find('')).to be_nil
    end

    context 'user is persisted' do
      let(:body) { double(:body, read: double(:read)) }
      let(:get) { double(:s3_get, body: body) }
      let(:object) { double(:object, get: get) }

      before do
        allow(bucket).to receive(:object).and_return(object)
        subject.find('ABC123')
      end

      it 'checks to see if the user record is already persisted' do
        # This may not work with mutation testing:
        # https://relishapp.com/rspec/rspec-mocks/docs/basics/spies
        expect(bucket).to have_received(:object).with('users/ABC123')
      end

      it 'calls .read on the body (required for s3)' do
        expect(body).to have_received(:read)
      end

      it 'symbolizes the JSON names (keys)' do
        expect(JSON).to have_received(:parse).with(anything, symbolize_names: true)
      end

      it 'parses the persisted record' do
        expect(JSON).to have_received(:parse)
      end

      context 'creates an OpenStruct object representing the user' do
        it 'has the id' do
          expect(OpenStruct).to have_received(:new).with(hash_including(id: 'ABC123'))
        end

        it 'has the email' do
          expect(OpenStruct).to have_received(:new).with(hash_including(email: anything))
          expect(parsed_json).to have_received(:fetch).with(:email)
        end

        it 'has the profile link' do
          expect(OpenStruct).to have_received(:new).with(hash_including(profile: anything))
          expect(parsed_json).to have_received(:fetch).with(:profile)
        end

        it 'has the logout link' do
          expect(OpenStruct).to have_received(:new).with(hash_including(logout: anything))
          expect(parsed_json).to have_received(:fetch).with(:logout)
        end
      end
    end
  end

  describe '.create' do
    let(:object) { double.as_null_object }
    let(:params) { { email: 'bob@test.com', profile: '<profile url>', logout: '<logout url>' } }

    before do
      allow(bucket).to receive(:object).and_return(object)
      subject.create('ABC123', params)
    end

    it 'instantiates the new user object' do
      # This may not work with mutation testing:
      # https://relishapp.com/rspec/rspec-mocks/docs/basics/spies
      expect(bucket).to have_received(:object).with('users/ABC123')
    end

    it 'persists the user object' do
      expect(object).to have_received(:put).with({ body: params.to_json })
    end
  end
end
