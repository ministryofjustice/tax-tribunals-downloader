require 'oauth2'

module TaxTribunal
  class Login < Downloader
    ORGANISATION = ENV.fetch('MOJSSO_ORG')
    ROLE = ENV.fetch('MOJSSO_ROLE')
    CALLBACK_URI = ENV.fetch('MOJSSO_CALLBACK_URI')
    TOKEN_REDIRECT_URI = ENV.fetch('MOJSSO_TOKEN_REDIRECT_URI')

    get '/login' do
      if session[:email].nil?
        redirect oauth_client.auth_code.authorize_url(redirect_uri: CALLBACK_URI)
      else
        session[:already_logged_in] = "You are already logged in as #{session[:email]}."
        erb :root
      end
    end

    get '/logout' do
      session.destroy
      erb :root
    end

    get '/oauth/callback' do
      resp = authorise!(params[:code])
      if resp
        session[:email] = resp[:email]
        session[:logout] = resp[:links][:logout]
        session[:profile] = resp[:links][:profile]
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
        resp
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
