require 'spec_helper'

RSpec.describe TaxTribunal::Healthcheck do
  let(:response) {
    JSON.parse(
      last_response.body,
      symbolize_names: true
    )
  }

  before do
    get '/healthcheck'
  end

  context 'operating normally' do
    describe 'service_status' do
      specify do
        expect(response[:service_status]).to eq('ok')
      end
    end

    describe 'read_test' do
      specify do
        expect(response[:dependencies][:s3][:read_test]).to eq('ok')
      end
    end
  end
end
