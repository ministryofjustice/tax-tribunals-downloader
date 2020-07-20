require 'spec_helper'

RSpec.describe TaxTribunal::User do
  subject { described_class }
  let(:storage) { double(:storage) }
  let(:container_name) { 'dummy-user-container' }

  before do
    allow(described_class).to receive(:storage).and_return(storage)
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
      let(:data) { { email: 'bob@test.com', profile: '<profile url>', logout: '<logout url>' }.to_json }

      before do
        expect(subject).to receive(:get_user).and_return(data)
        subject.find('ABC123')
      end

      it 'symbolizes the JSON names (keys)' do
        expect(JSON).to have_received(:parse).with(data, symbolize_names: true)
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
    let(:storage) { double.as_null_object }
    let(:data) { { email: 'bob@test.com', profile: '<profile url>', logout: '<logout url>' } }
    let(:blob_name) { 'users/ABC123' }

    before do
      subject.create('ABC123', data)
    end

    it 'persists the user object' do
      expect(storage).to have_received(:create_block_blob).with(container_name, blob_name, data.to_json)
    end
  end

  describe '.user_id' do
    let(:user_id) { 'users/ABC123' }

    it "adds the dir prefix 'users/' to the user id" do
      expect(user_id).to eql('users/ABC123')
    end
  end
end
