# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.1.2'

gem 'grape'
gem 'rack'

gem 'dry-auto_inject'
gem 'dry-monads'
gem 'dry-system'
gem 'dry-types'
gem 'dry-validation'

gem 'sidekiq'
gem 'sidekiq-scheduler', '~> 5.0'

gem 'rom'
gem 'rom-sql'

gem 'pg'

gem 'net-ping', '~> 2.0', '>= 2.0.8'

gem 'puma'

group :development do
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'database_cleaner-sequel'
  gem 'rack-test'
  gem 'rom-factory'
  gem 'rspec'
end

group :development, :test do
  gem 'pry'
end
