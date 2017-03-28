require 'oauth2'

module TaxTribunal
  class Login < Downloader
    ORG = ENV.fetch('MOJSSO_ORG')
    ROLE = ENV.fetch('MOJSSO_ROLE')
    CALLBACK_URI = ENV.fetch('MOJSSO_CALLBACK_URI')
    TOKEN_REDIRECT_URI = ENV.fetch('MOJSSO_TOKEN_REDIRECT_URI')

    get '/login' do
      if logged_in?
        log_result(action: 'login', state: 'exists', message: current_user.email)
        erb :root
      else
        session[:auth_key] = SecureRandom.uuid
        log_result(action: 'login', state: 'new', message: session[:return_to])
        redirect oauth_client.auth_code.authorize_url(
          redirect_uri: "#{CALLBACK_URI}?auth_key=#{session[:auth_key]}&return_to=#{session[:return_to]}"
        )
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
        authorise!(params[:code], params[:auth_key], params[:return_to]).tap { |resp|
          if resp&.key?(:email) && resp&.key?(:links)
            email = resp.fetch(:email)
            links = resp.fetch(:links)
            User.create(params[:auth_key], email: email, logout: links.fetch(:logout), profile: links.fetch(:profile))
            log_result(action: 'oauth/callback', user_persisted: email)
          else
            log_result(resp.merge(action: 'oauth/callback', error: 'user not persisted'))
          end
        }
      end
      redirect "#{request.base_url}#{params[:return_to]}"
    end

    private

    def log_result(params)
      params.fetch(:error, nil) ? logger.error(params) : logger.info(params)
    end

    def authorise!(code, auth_key, return_to)
      token = oauth_client.auth_code.get_token(
        code,
        redirect_uri: "#{TOKEN_REDIRECT_URI}?auth_key=#{auth_key}&return_to=#{return_to}"
      )
      token_response = token.get('/api/user_details')

      resp = JSON.parse(token_response.body, symbolize_names: true)
      resp if authorised?(resp.fetch(:permissions, {}))
    end

    def authorised?(permissions)
      permissions.any? { |p| p.fetch(:organisation).eql?(ORG) && p.fetch(:roles).include?(ROLE) }
    end

    def oauth_client
      OAuth2::Client.new(
        ENV.fetch('MOJSSO_ID'),
        ENV.fetch('MOJSSO_SECRET'),
        site: ENV.fetch('MOJSSO_URL')
      )
    end
  end
end
