# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.0'

# AASM is a library for adding finite state machines to Ruby classes.
gem 'aasm', '~> 5.5'

# ActiveModel::Serializers allows you to generate your JSON in an object-oriented and convention-driven manner.
gem 'active_model_serializers', '~> 0.10.14'

# Bootsnap is a library that plugs into Ruby, with optional support for YAML and JSON, to optimize and cache expensive computations.
gem 'bootsnap', '>= 1.4.4', require: false

# Data Migrate is a database migration tool for ActiveRecord.
gem 'data_migrate', '~> 9.3'

# Simple, multi-client and secure token-based authentication for Rails (based on Devise).
gem 'devise_token_auth', '~> 1.2'

# Faraday is an HTTP client library that provides a common interface over many adapters (such as Net::HTTP) and embraces the concept of Rack middleware when processing the request/response cycle.
gem 'faraday', '~> 2.9'

# Kaminari is a gem for paginating arrays and ActiveRecord scopes.
gem 'kaminari', '~> 1.2'

# Pg is the Ruby interface to the PostgreSQL RDBMS.
gem 'pg', '~> 1.1'

# Puma is a simple, fast, threaded, and highly concurrent HTTP 1.1 server for Ruby/Rack applications.
gem 'puma', '~> 5.0'

# Rails is a web-application framework that includes everything needed to create database-backed web applications according to the Model-View-Controller (MVC) pattern.
gem 'rails', '~> 6.1.4', '>= 6.1.4.4'

# Sidekiq is a simple, efficient background processing library for Ruby.
gem 'sidekiq', '~> 6.5', '>= 6.5.12'

# Sidekiq-cron is an extension to Sidekiq that adds support for running scheduled jobs.
gem "sidekiq-cron", "~> 1.12"

# Tzinfo provides access to time zone data and allows times to be converted using time zone rules
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  # Byebug is a Ruby debugger.
  gem 'byebug', platforms: %i[mri mingw x64_mingw]

  # Factory_bot_rails is a fixtures replacement with a straightforward definition syntax, support for multiple build strategies (saved instances, unsaved instances), and support for multiple factories for the same class (user, admin_user, and so on), including factory inheritance.
  gem 'factory_bot_rails', '~> 6.4'

  # Faker is a library for generating fake data such as names, addresses, and phone numbers.
  gem 'faker', '~> 3.3'

  # Pry is a runtime developer console and IRB alternative with powerful introspection capabilities.
  gem 'pry', '~> 0.14.2'

  # Rspec-rails is a testing framework for Rails 3.x, 4.x and 5.x.
  gem 'rspec-rails', '~> 6.1'

  # Redis-lock is a distributed lock manager built on top of Redis.
  gem "redis-lock", "~> 0.2.0"
end

group :development do
  # Letter Opener delivers your email with the browser instead of sending it.
  gem 'letter_opener', '~> 1.10'

  # Listen to file modifications and notify about the changes.
  gem 'listen', '~> 3.3'

  # Spring speeds up development by keeping your application running in the background.
  gem 'spring'
end

group :test do
  # Database Cleaner is a set of strategies for cleaning your database in Ruby.
  gem 'database_cleaner-active_record', '~> 2.1'

  # Shoulda Matchers provides RSpec- and Minitest-compatible one-liners that test common Rails functionality.
  gem 'shoulda-matchers', '~> 6.2'

  # Rspec-sidekiq is a set of matchers to test your Sidekiq jobs.
  gem 'rspec-sidekiq', '~> 4.2'

  # Simplecov is a code coverage analysis tool for Ruby.
  gem 'simplecov', '~> 0.22.0'

  # Simplecov_json_formatter is a JSON formatter for SimpleCov.
  gem 'simplecov_json_formatter', '~> 0.1.4'

  # VCR is a gem that records your test suite's HTTP interactions and replays them during future test runs for fast, deterministic, accurate tests.
  gem 'vcr', '~> 6.2'
end