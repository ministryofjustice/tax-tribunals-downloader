require 'spec_helper'

RSpec.describe TaxTribunal::File do
  let(:key) { '9473fc9c-4635-4030-96ac-1618ac9c1aaa/test_file_name.txt' }
  let(:bucket) { double('bucket')}
  let(:s3object) { double('s3object') }

  subject { described_class.new(key) }

  describe '#name' do
    it 'strips the collection reference' do
      expect(subject.name).to eq('test_file_name.txt')
    end
  end

  describe '#s3_url' do
    before do
      allow(subject).to receive(:bucket).and_return(bucket)
      expect(bucket).to receive(:object).with(key).and_return(s3object)
    end

    it 'returns a pre-signed url' do
      expect(s3object).to receive(:presigned_url).with(:get, expires_in: 3600)
      subject.s3_url
    end
  end
end
