require 'oauth2'

module TaxTribunal
  class Login < Downloader
    ORGANISATION = ENV.fetch('MOJSSO_ORG')
    ROLE = ENV.fetch('MOJSSO_ROLE')
    CALLBACK_URI = ENV.fetch('MOJSSO_CALLBACK_URI')
    TOKEN_REDIRECT_URI = ENV.fetch('MOJSSO_TOKEN_REDIRECT_URI')

    get '/login' do
      if logged_in?
        logger.info({ action: 'login', state: 'existing', message: current_user.email})
        erb :root
      else
        session[:auth_key] = SecureRandom.uuid
        logger.info({ action: 'login', state: 'new', message: 'new login', requested: session[:return_to] })
        redirect oauth_client.auth_code.authorize_url(
          redirect_uri: "#{CALLBACK_URI}?auth_key=#{session[:auth_key]}&return_to=#{session[:return_to]}"
        )
      end
    end

    get '/logout' do
      logger.info({ action: 'logout', message: current_user.email }) if logged_in?
      session.destroy
      erb :root
    end

    get '/oauth/callback' do
      halt(422) unless params[:code] && params[:auth_key] && params[:return_to]
      if (user = User.find(params[:auth_key]))
        logger.info(
          {
            action: '/oauth/callback',
            message: "already persisted #{user.email} to #{params[:auth_key]}",
            requested: params[:return_to]
          }.to_json
        )
      else
        resp = authorise!(params[:code], params[:auth_key], params[:return_to])
        persist_user!(resp)
      end
      redirect "#{request.base_url}#{params[:return_to]}"
    end

    private

    def persist_user!(resp)
      if (email = resp.fetch(:email, nil)) && (links = resp.fetch(:links))
        User.create(params[:auth_key], email: email, logout: links.fetch(:logout), profile: links.fetch(:profile))
        logger.info(
          {
            action: '/oauth/callback',
            message: "persisted #{resp.fetch(:email)} to #{params[:auth_key]}",
            requested: params[:return_to]
          }.to_json
        )
      else
        logger.info({ action: '/oauth/callback', method: 'persist_user!', status: 'failed', message: resp }.to_json)
      end
    end

    def authorise!(code, auth_key, return_to)
      resp = oauth_response(code, auth_key, return_to)

      if resp.fetch(:permissions).any? { |permission|
        permission.fetch(:organisation).eql?(ORGANISATION) &&
          permission.fetch(:roles).include?(ROLE)
      }
        resp
      else
        {}
      end
    end

    def oauth_response(code, auth_key, return_to)
      token = oauth_client.auth_code.get_token(
        code,
        redirect_uri: "#{TOKEN_REDIRECT_URI}?auth_key=#{auth_key}&return_to=#{return_to}"
      )
      resp = token.get('/api/user_details')
      JSON.parse(resp.body, symbolize_names: true)
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
