require 'raven'
require_relative 'lib/tax_tribunal'

# Will use SENTRY_DSN environment variable if set
use Raven::Rack

run TaxTribunal::App
