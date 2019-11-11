require 'spec_helper'

RSpec.describe TaxTribunal::ContainerStatus do
  specify do
    expect(described_class).to respond_to(:readable?)
  end

  specify do
    expect(described_class).to receive_message_chain('storage.list_blobs')
    described_class.readable?
  end
end
