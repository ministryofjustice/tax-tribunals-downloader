require 'spec_helper'

RSpec.describe TaxTribunal::BucketStatus do
  specify do
    expect(described_class).to respond_to(:readable?)
  end

  specify do
    bucket_status = instance_double(described_class)
    expect(described_class).to receive(:new).and_return(bucket_status)
    expect(bucket_status).to receive_message_chain('objects.first.exists?')
    described_class.readable?
  end
end
