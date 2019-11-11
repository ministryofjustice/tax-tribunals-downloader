require 'logger'
require 'logstash-logger'

module TaxTribunal
  class Downloader < Sinatra::Base
    # This is exceptionally difficult to stub and any issues will get bubbled
    # up to the application anyway.
    # :nocov:
    configure :production, :development do
      enable :logging
      use Rack::CommonLogger, LogStashLogger.new(type: :stdout)
    end

    configure do
      enable :sessions
      set :views, "#{settings.root}/../../views"
      set :public_folder, "#{settings.root}/../../public"
      set :container_status, ContainerStatus
    end
    # :nocov:

    def current_user
      @current_user ||= User.find(session.fetch(:auth_key))
    end

    def logged_in?
      !current_user.nil?
    end
  end
end
