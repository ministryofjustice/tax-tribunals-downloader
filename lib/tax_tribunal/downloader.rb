module TaxTribunal
  class Downloader < Sinatra::Base
    enable :sessions

    configure do
      set :raise_errors, true
      set :show_exceptions, false
      set :views, "#{settings.root}/../../views"
      set :public_folder, "#{settings.root}/../../public"
    end
  end
end
