module TaxTribunal
  class Download < Downloader
    get '/:case_id' do |case_id|
      # Using the session directly as encapsulating the session in an
      # authorised? helper method results in intermittent spec failures,
      # even when the email is not set on the session.
      if session[:email]
        logger.info({ action: 'download', state: 'authorised', user: session[:email], case: case_id })
        @case = Case.new(case_id)
      else
        logger.info({ action: 'download', state: 'unauthorised', case: case_id })
        session[:return_to] = "/#{case_id}"
      end

      erb :show
    end
  end
end
