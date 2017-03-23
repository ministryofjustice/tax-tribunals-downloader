require 'sinatra'
require 'securerandom'

require_relative 'tax_tribunal/case'
# Load order is important, alphabetical otherwise
require_relative 'tax_tribunal/downloader'
require_relative 'tax_tribunal/download'

require_relative 'tax_tribunal/file'
require_relative 'tax_tribunal/healthcheck'
require_relative 'tax_tribunal/login'
require_relative 'tax_tribunal/root'
require_relative 'tax_tribunal/user'

module TaxTribunal
  class App < Sinatra::Base
    # Use caution when changing the ordering.
    use Login
    use Healthcheck
    use Root
    use Download
  end
end
