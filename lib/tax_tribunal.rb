require 'sinatra'
require 'securerandom'

require_relative 'tax_tribunal/case'
# Load order is important, alphabetical otherwise
require_relative 'tax_tribunal/downloader'
require_relative 'tax_tribunal/download'

require_relative 'tax_tribunal/file'
require_relative 'tax_tribunal/login'
require_relative 'tax_tribunal/root'
require_relative 'tax_tribunal/user'
require_relative 'tax_tribunal/status'

module TaxTribunal
  class App < Sinatra::Base
    # Use caution when changing the ordering.
    use Status
    use Login
    use Root
    use Download
  end
end
