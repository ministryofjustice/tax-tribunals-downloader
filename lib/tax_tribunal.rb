require 'sinatra'
require 'securerandom'
require 'azure/storage/blob'
require 'dotenv/load'

# Load order is important, alphabetical otherwise
require_relative 'tax_tribunal/azure_blob_storage'
require_relative 'tax_tribunal/container_status'
require_relative 'tax_tribunal/case'
require_relative 'tax_tribunal/downloader'
require_relative 'tax_tribunal/download'

require_relative 'tax_tribunal/file'
require_relative 'tax_tribunal/login'
require_relative 'tax_tribunal/root'
require_relative 'tax_tribunal/user'
require_relative 'tax_tribunal/status'

module TaxTribunal
  class App < Sinatra::Base
    get '/.well-known/acme-challenge/XFd8L9wrWbH-Vl-LAgL28modf0wPuMrbJnoYsCDL1VU' do
      'XFd8L9wrWbH-Vl-LAgL28modf0wPuMrbJnoYsCDL1VU.uEiE3VdULErBkWa7cFa-BvuUKSFhPSggLsDJjQzu0Es'
    end

    # Use caution when changing the ordering.
    use Status
    use Login
    use Root
    use Download
  end
end
