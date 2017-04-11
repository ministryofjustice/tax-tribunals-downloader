require 'oauth2'

module TaxTribunal
  class SsoClient
    ORG = ENV.fetch('MOJSSO_ORG')
    ROLE = ENV.fetch('MOJSSO_ROLE')
    CALLBACK_URI = ENV.fetch('MOJSSO_CALLBACK_URI')
    TOKEN_REDIRECT_URI = ENV.fetch('MOJSSO_TOKEN_REDIRECT_URI')

    def authorize_url(session)
      auth_key = session[:auth_key]
      return_to = session[:return_to]
      oauth_client.auth_code.authorize_url(
        redirect_uri: "#{CALLBACK_URI}?auth_key=#{auth_key}&return_to=#{return_to}"
      )
    end

    def authorize!(code, auth_key, return_to)
      token = oauth_client.auth_code.get_token(
        code,
        redirect_uri: "#{TOKEN_REDIRECT_URI}?auth_key=#{auth_key}&return_to=#{return_to}"
      )
      token_response = token.get('/api/user_details')

      resp = JSON.parse(token_response.body, symbolize_names: true)
      resp if authorized?(resp.fetch(:permissions, {}))
    end

    def authorized?(permissions)
      permissions.any? { |p| p.fetch(:organisation).eql?(ORG) && p.fetch(:roles).include?(ROLE) }
    end

    private

    def oauth_client
      OAuth2::Client.new(
        ENV.fetch('MOJSSO_ID'),
        ENV.fetch('MOJSSO_SECRET'),
        site: ENV.fetch('MOJSSO_URL')
      )
    end
  end
end
