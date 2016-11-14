RSpec.describe TaxTribunal::Root do
  describe '/' do
    # No reason to ever call it without a bucket.
    it 'returns 403' do
      get '/'
      expect(last_response.status).to eq(403)
    end
  end
end

