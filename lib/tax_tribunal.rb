require 'sinatra'
require_relative 'tax_tribunal/case'
require_relative 'tax_tribunal/file'

module TaxTribunal
  class Downloader < Sinatra::Base
    configure do
      set :raise_errors, true
      set :show_exceptions, false
    end

    get '/:case_id' do |case_id|
      @case = Case.new(case_id)
      erb :show
    end
  end
end
