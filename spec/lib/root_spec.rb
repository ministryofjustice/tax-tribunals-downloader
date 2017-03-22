RSpec.describe TaxTribunal::Root do
  describe '/' do
    # No reason to ever call it without a bucket.
    it 'returns 403' do
      get '/'
      expect(last_response.status).to eq(403)
    end
  end

  describe '/robots.txt' do
    # No reason to ever call it without a bucket.
    it 'returns 200' do
      get '/robots.txt'
      expect(last_response.status).to eq(200)
    end

    it 'returns text/plain' do
      get '/robots.txt'
      expect(last_response.headers['Content-Type']).to match(/text\/plain/)
    end

    it 'disallows all robots' do
      get '/robots.txt'
      expect(last_response.body).to eq("User-agent: *\nDisallow: /")
    end
  end
end
