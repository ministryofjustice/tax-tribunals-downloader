require 'spec_helper'

RSpec.describe TaxTribunal::Case do
  describe '#exists?' do
    specify { expect(described_class.new('12345').exists?).to be_truthy }
    specify { expect(described_class.new('junky').exists?).to be_falsey }
  end

  describe '#files' do
    subject { described_class.new('12345').files }

    it 'returns an array of File objects' do
      subject.each do |file|
        expect(file).to be_an_instance_of(TaxTribunal::File)
      end
    end

    it 'only shows the files and skips the directories' do
      expect(subject.map{ |f| f.key }).to eq(['12345/testfile.docx'])
    end
  end
end
