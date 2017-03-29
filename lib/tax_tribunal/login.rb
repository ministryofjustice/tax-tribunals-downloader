require_relative 'sso_client'

module TaxTribunal
  class Login < Downloader
    extend Forwardable

    get '/login' do
      if logged_in?
        log_result(action: 'login', state: 'exists', message: current_user.email)
        erb :root
      else
        session[:auth_key] = SecureRandom.uuid
        log_result(action: 'login', state: 'new', message: session[:return_to])

        redirect authorize_url(session)
      end
    end

    get '/logout' do
      log_result(action: 'logout', message: current_user.email) if logged_in?
      session.destroy
      erb :root
    end

    get '/oauth/callback' do
      halt(422) if params.values_at(:code, :auth_key, :return_to).any?(&:nil?)
      if (user = User.find(params[:auth_key]))
        # No action required beyond logging.
        log_result(action: 'oauth/callback', user_found: user.email)
      else
        auth = authorize!(params[:code], params[:auth_key], params[:return_to])
        if auth.key?(:email) && auth.key?(:links)
          email = auth.fetch(:email)
          links = auth.fetch(:links)
          User.create(params[:auth_key], email: email, logout: links.fetch(:logout), profile: links.fetch(:profile))
          log_result(action: 'oauth/callback', user_persisted: email)
        else
          log_result(auth.merge(action: 'oauth/callback', error: 'user not persisted'))
        end
      end
      redirect "#{request.base_url}#{params[:return_to]}"
    end

    private

    def sso_client
      SsoClient.new
    end
    def_delegators :sso_client, :authorize!, :authorize_url

    def log_result(params)
      params.fetch(:error, nil) ? logger.error(params) : logger.info(params)
    end
  end
end
