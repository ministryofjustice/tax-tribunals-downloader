module TaxTribunal
  class Downloader < Sinatra::Base
    configure do
      set :raise_errors, true
      set :show_exceptions, false
      set :views, "#{settings.root}/../../views"
    end

    get '/:case_id' do |case_id|
      @case = Case.new(case_id)
      erb :show
    end
  end
end
