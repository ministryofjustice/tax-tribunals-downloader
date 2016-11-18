ENV['RACK_ENV'] = 'test'
require 'dotenv'
Dotenv.load

require 'simplecov'
SimpleCov.minimum_coverage 100
# SimpleCov conflicts with mutant. This lets us turn it off, when necessary.
SimpleCov.start unless ENV['NOCOVERAGE']

require_relative '../lib/tax_tribunal'
require 'rspec'
require 'rack/test'
require 'vcr'
require 'pry'

ENV['RACK_ENV'] = 'test'

def app
  TaxTribunal::App
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
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

  config.around(:each) do |example|
    VCR.use_cassette(:cases, record: :once) do
      example.run
    end
  end
end
