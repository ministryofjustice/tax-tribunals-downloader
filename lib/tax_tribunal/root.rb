require 'oauth2'

module TaxTribunal
  class Root < Downloader

    get '/' do
      return 403
    end
  end
end
