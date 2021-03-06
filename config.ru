# Azure Key Vault secrets to ENV variables
require 'azure_env_secrets'
::AzureEnvSecrets.load

require 'application_insights'
require 'raven'
require_relative 'lib/tax_tribunal'

use ApplicationInsights::Rack::TrackRequest, ENV['AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY']

Raven.configure do |config|
  config.ssl_verification = ENV['SENTRY_SSL_VERIFICATION'] == true
end

# Will use SENTRY_DSN environment variable if set
use Raven::Rack

run TaxTribunal::App
