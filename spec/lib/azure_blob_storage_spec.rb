require 'spec_helper'

RSpec.describe TaxTribunal::AzureBlobStorage do
  let(:object) do
    Class.new do
      include TaxTribunal::AzureBlobStorage
    end
  end

  it 'adds a Blob Service to the class' do
    expect(object.new.storage).to be_an_instance_of(Azure::Storage::Blob::BlobService)
  end

  it 'adds a Shared Access Signature to the class' do
    expect(object.new.signer).to be_an_instance_of(Azure::Storage::Common::Core::Auth::SharedAccessSignature)
  end

  it 'fetches the account and access key from the ENV' do
    object.new.storage
  end
end
