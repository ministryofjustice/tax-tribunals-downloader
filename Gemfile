source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '2.7.5'

gem 'activesupport'
gem 'application_insights', '~> 0.5.6'
gem 'azure_env_secrets', github: 'ministryofjustice/azure_env_secrets', tag: 'v0.1.3'
gem 'azure-storage-blob', '~> 2'
gem 'azure-storage-common', '~> 2'
gem 'erubis'
gem 'logstash-logger'
gem 'oauth2'
gem 'pry'
gem 'puma'
gem 'rake'
gem 'sentry-ruby', '~> 4.6'
gem 'sinatra', '~> 2.1'
gem 'sinatra-router', '~> 0.2.4'

group :development, :test do
  gem 'dotenv'
  gem 'mutant-rspec'
  gem 'pry-byebug'
  gem 'rspec', '~> 3.9'
end

group :test do
  gem 'brakeman'
  gem 'cucumber'
  gem 'fuubar'
  gem 'phantomjs'
  gem 'poltergeist'
  gem 'rack-test'
  gem 'rspec_junit_formatter', '~> 0.4.1'
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false
  gem 'vcr'
  gem 'webmock'
end
