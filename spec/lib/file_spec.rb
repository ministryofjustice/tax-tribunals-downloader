require 'spec_helper'

RSpec.describe TaxTribunal::File do
  let(:key) { '9473fc9c-4635-4030-96ac-1618ac9c1aaa/test_file_name.txt' }
  let(:signer) { double('signer') }

  subject { described_class.new(key) }

  describe '#name' do
    it 'strips the collection reference' do
      expect(subject.name).to eq('test_file_name.txt')
    end
  end

  describe '#url' do
    it 'returns a pre-signed url' do
      expect(subject).to receive(:signer).and_return(signer)
      expect(signer).to receive(:signed_uri)
      subject.url
    end
  end
end
