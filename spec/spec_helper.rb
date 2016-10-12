require 'simplecov'
SimpleCov.minimum_coverage 100
# SimpleCov conflicts with mutant. This lets us turn it off, when necessary.
SimpleCov.start unless ENV['NOCOVERAGE']

require_relative '../lib/tax_tribunal'
require 'rspec'
require 'capybara/rspec'
require 'vcr'

ENV['RACK_ENV'] = 'test'

def app
  TaxTribunal::Downloader
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
end

Capybara.app = TaxTribunal::Downloader

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.around(:each) do |example|
    original_key = ENV['ACCESS_KEY_ID']
    original_secret = ENV['SECRET_ACCESS_KEY']
    original_bucket = ENV['BUCKET_NAME']

    ENV['BUCKET_NAME'] = 'tax-tribs-doc-upload-test'
    ENV['ACCESS_KEY_ID'] = 'dummy key'
    ENV['SECRET_ACCESS_KEY'] = 'dummy secret'

    VCR.use_cassette(:cases, record: :once) do
      example.run
    end

    ENV['BUCKET_NAME'] = original_bucket
    ENV['ACCESS_KEY_ID'] = original_key
    ENV['SECRET_ACCESS_KEY'] = original_secret
  end
end
