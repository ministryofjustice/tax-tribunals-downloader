ENV['RACK_ENV'] = 'test'
require 'dotenv'
Dotenv.load

require 'simplecov'
SimpleCov.minimum_coverage 85
# SimpleCov conflicts with mutant. This lets us turn it off, when necessary.
SimpleCov.start unless ENV['NOCOVERAGE']

require_relative '../lib/tax_tribunal'
require 'rspec'
require 'rack/test'
require 'pry'
# This is here to ensure that we do not accidentally make external calls.
require 'webmock/rspec'

ENV['RACK_ENV'] = 'test'

def app
  TaxTribunal::App
end

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  ENV['AZURE_STORAGE_ACCOUNT'] = 'dummy-account'
  ENV['AZURE_STORAGE_ACCESS_KEY'] = 'ZHVtbXktYWNjZXNzLWtleSBrZXk='
  ENV['USER_CONTAINER_NAME'] = 'dummy-user-container'
  ENV['FILES_CONTAINER_NAME'] = 'dummy-files-container'
end
