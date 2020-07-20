require 'spec_helper'

RSpec.describe TaxTribunal::Case do
  subject { described_class.new('12345') }
  let(:file) { double(name: 'value') }
  let(:directory) { double(name: '/') }

  describe '#files' do
    before do
      allow(subject).to receive_message_chain('storage.list_blobs').and_return([file, directory])
    end

    it 'returns an array of File objects' do
      expect(subject.files).to be_an_instance_of(Array)
      expect(subject.files.first).to be_an_instance_of(TaxTribunal::File)
    end

    it 'instantiates a new file object for each non-directory listing from #objects' do
      expect(TaxTribunal::File).to receive(:new).with('value')
      subject.files
    end

    it 'does not instantiate file objects for keys with trailing slashes (directories)' do
      expect(TaxTribunal::File).not_to receive(:new).with('/')
      subject.files
    end
  end
end
