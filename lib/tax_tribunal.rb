require 'sinatra'
require_relative 'tax_tribunal/downloader'
require_relative 'tax_tribunal/case'
require_relative 'tax_tribunal/file'
require_relative 'tax_tribunal/download'
require_relative 'tax_tribunal/login'
require_relative 'tax_tribunal/root'

module TaxTribunal
  class App < Sinatra::Base
    use Login
    use Download
    use Root
  end
end
