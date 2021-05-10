require 'spec_helper'

RSpec.describe TaxTribunal::Downloader do
  # Sinatra overrides #new, so this has to be instantiated with #new!
  subject { described_class.new! }
  let(:session) { double }

  describe '#current_user' do
    it 'uses session[:auth_key] to find the current user' do
      expect(session).to receive(:[]).with(:auth_key)
      allow(subject).to receive(:session).and_return(session)
      subject.current_user
    end

    it 'calls User#find' do
      allow(session).to receive(:[]).with(:auth_key).and_return(12_345)
      allow(subject).to receive(:session).and_return(session)
      expect(TaxTribunal::User).to receive(:find).with(12_345)
      subject.current_user
    end
  end

  context 'not logged in' do
    describe '#logged_in?' do
      specify do
        allow(subject).to receive(:current_user).and_return(double(nil?: true))
        expect(subject.logged_in?).to eq(false)
      end
    end
  end

  context 'logged in' do
    describe '#logged_in?' do
      specify do
        allow(subject).to receive(:current_user).and_return(double(nil?: false))
        expect(subject.logged_in?).to eq(true)
      end
    end
  end
end
