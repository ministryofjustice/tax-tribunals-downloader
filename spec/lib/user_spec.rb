require 'spec_helper'

RSpec.describe TaxTribunal::User do
  # WARNING Magic:
  # The S3 bucket `tax-tribs-doc-upload-test` contains the example file
  # `users/12345`. The interaction is recorded into the main vcr cassette,
  # `cases.yml`.  Add new episodes or re-record as needed.  Ultimately, it was
  # simpler to do it this way than it was to try and stub out the full aws-sdk
  # S3 interaction.

  describe '.find' do
    # This ensures the record exists on the S3 test bucket if you need to re-record the cassette.
    before do
      TaxTribunal::User.create('12345', email: 'bob@example.com', profile: 'http://sso-profile-link', logout: 'http://sso-logout-link')
    end

    it 'returns a populated openstruct if the key exists' do
      expect(described_class.find('12345')).
        to eq(OpenStruct.new(id: '12345', email: 'bob@example.com', profile: 'http://sso-profile-link', logout: 'http://sso-logout-link'))
    end

    it 'returns nil if the key does not exist' do
      expect(described_class.find('junky')).to be_nil
    end

    it 'works with nil' do
      expect(described_class.find(nil)).to be_nil
    end

    it 'works with empty strings' do
      expect(described_class.find('')).to be_nil
    end
  end

  describe '.create' do
    let(:user_obj) { double(:user_obj) }
    let(:bucket) { double(:bucket) }

    # Finding the record after the create call will generate a false positive
    # owing to the fact that the aws-sdk call is recorded. This ensures aws-sdk
    # is called with the correct parameters.
    it 'puts a new record to the bucket' do
      expect(user_obj).to receive(:put).with(body: "{\"email\":\"suzy@test.com\",\"profile\":\"http://sso-profile\",\"logout\":\"http://sso-logout\"}")
      expect(described_class).to receive(:user_obj).and_return(user_obj)
      described_class.create('23456', email: 'suzy@test.com', logout: 'http://sso-logout', profile: 'http://sso-profile')
    end

    it 'puts the record using the correct key (mutation)' do
      expect(bucket).to receive(:object).with('users/23456').and_return(user_obj.as_null_object)
      expect(described_class).to receive(:bucket).and_return(bucket)
      described_class.create('23456', email: 'suzy@test.com', logout: 'http://sso-logout', profile: 'http://sso-profile')
    end
  end
end
