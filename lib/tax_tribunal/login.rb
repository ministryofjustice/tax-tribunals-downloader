require 'oauth2'

module TaxTribunal
  class Login < Downloader
    ORGANISATION = ENV.fetch('MOJSSO_ORG')
    ROLE = ENV.fetch('MOJSSO_ROLE')
    CALLBACK_URI = ENV.fetch('MOJSSO_CALLBACK_URI')
    TOKEN_REDIRECT_URI = ENV.fetch('MOJSSO_TOKEN_REDIRECT_URI')

    get '/login' do
      if session[:email].nil?
        logger.info({ action: 'login', state: 'new', message: 'new login', requested: session[:return_to] })
        redirect oauth_client.auth_code.authorize_url(redirect_uri: CALLBACK_URI)
      else
        logger.info({ action: 'login', state: 'existing', message: session[:email] })
        session[:already_logged_in] = "You are already logged in as #{session[:email]}."
        erb :root
      end
    end

    get '/logout' do
      logger.info({ action: 'logout', message: session[:email] })
      session.destroy
      erb :root
    end

    get '/oauth/callback' do
      resp = authorise!(params[:code])
      links = resp.fetch(:links, {})
      if resp.fetch(:email, false) && links.fetch(:logout, false) && links.fetch(:profile, false)
        session[:email] = resp[:email]
        session[:logout] = links[:logout]
        session[:profile] = links[:profile]
      else
        logger.info({ action: '/oauth/callback', status: 'failed', message: resp }.to_json)
      end
      redirect session.delete(:return_to) || '/logout'
    end

    private

    def authorise!(code)
      resp = oauth_response(code)

      if resp.fetch(:permissions).any? { |permission|
        permission.fetch(:organisation).eql?(ORGANISATION) &&
          permission.fetch(:roles).include?(ROLE)
      }
        logger.info({ action: 'authorise!', message: resp }.to_json)
        resp
      else
        {}
      end
    end

    def oauth_response(code)
      JSON.parse(oauth_call(code), symbolize_names: true)
    end

    def oauth_call(code)
      token = oauth_client.auth_code.get_token(code, redirect_uri: TOKEN_REDIRECT_URI)
      resp = token.get('/api/user_details')
      resp.body
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
