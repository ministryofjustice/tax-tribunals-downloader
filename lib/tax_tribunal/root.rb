require 'oauth2'

module TaxTribunal
  class Root < Downloader
    get '/robots.txt' do
      content_type 'text/plain'
      "User-agent: *\nDisallow: /"
    end

    get '/' do
      return 403
    end
  end
end
