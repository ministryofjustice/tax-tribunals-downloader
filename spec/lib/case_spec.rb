require 'spec_helper'

RSpec.describe TaxTribunal::Case do
  subject { described_class.new('12345') }
  let(:file) { double(key: 'value', match: nil) }
  let(:directory) { double(key: '/') }

  describe '#files' do
    before do
      expect(subject).to receive(:objects).with(prefix: '12345').and_return([file, directory])
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

  describe '#exists?' do
    context 'case has files' do
      before do
        expect(subject).to receive(:objects).with(prefix: '12345').and_return([file, directory])
      end

      specify do
        expect(subject.exists?).to be(true)
      end
    end

    context 'case does not have files' do
      before do
        expect(subject).to receive(:objects).with(prefix: '12345').and_return([])
      end

      specify do
        expect(subject.exists?).to be(false)
      end
    end
  end
end
