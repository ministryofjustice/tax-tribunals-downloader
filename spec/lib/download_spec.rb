require 'spec_helper'

RSpec.describe TaxTribunal::Download do
  describe 'get /:case_id' do
    let(:logger) { double.as_null_object }
    let(:user) { double.as_null_object }
    let(:case_object) { double.as_null_object }

    before do
      allow_any_instance_of(described_class).to receive(:current_user).and_return(user)
      allow_any_instance_of(described_class).to receive(:logger).and_return(logger)
      # Spec default context is 'authorized user'.
      allow_any_instance_of(described_class).to receive(:logged_in?).and_return(true)
      allow(TaxTribunal::Case).to receive(:new).with('abc123').and_return(case_object)
    end

    context 'authorized user' do
      it 'renders a template' do
        get '/abc123'
        expect(last_response.body).to include("<a href='/logout'>Logout</a>")
      end

      it 'instantiates a new Case object' do
        expect(TaxTribunal::Case).to receive(:new).with('abc123')
        get '/abc123'
      end

      it 'logs the request' do
        expect(logger).to receive(:info)
        get '/abc123'
      end
    end

    context 'unauthorized user' do
      before do
        expect_any_instance_of(described_class).to receive(:logged_in?).and_return(false)
      end

      it 'renders a template' do
        get '/abc123'
        expect(last_response.body).to include("<a href='/login'>Login</a>")
      end

      it 'does not instantiate a new Case object' do
        expect(TaxTribunal::Case).not_to receive(:new).with('abc123')
        get '/abc123'
      end

      it 'logs the request' do
        expect(logger).to receive(:info)
        get '/abc123'
      end
    end
  end
end
