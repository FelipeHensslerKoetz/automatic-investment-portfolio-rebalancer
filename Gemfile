# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.0'

# ActiveModel::Serializers allows you to generate your JSON in an object-oriented and convention-driven manner.
gem 'active_model_serializers', '~> 0.10.14'

# Bootsnap is a library that plugs into Ruby, with optional support for YAML and JSON, to optimize and cache expensive computations.
gem 'bootsnap', '>= 1.4.4', require: false

# Simple, multi-client and secure token-based authentication for Rails (based on Devise).
gem 'devise_token_auth', '~> 1.2'

# Pg is the Ruby interface to the PostgreSQL RDBMS.
gem 'pg', '~> 1.1'

# Puma is a simple, fast, threaded, and highly concurrent HTTP 1.1 server for Ruby/Rack applications.
gem 'puma', '~> 5.0'

# Rails is a web-application framework that includes everything needed to create database-backed web applications according to the Model-View-Controller (MVC) pattern.
gem 'rails', '~> 6.1.4', '>= 6.1.4.4'

# Tzinfo provides access to time zone data and allows times to be converted using time zone rules
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  # Byebug is a Ruby debugger.
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Letter Opener delivers your email with the browser instead of sending it.
  gem 'letter_opener', '~> 1.10'

  # Listen to file modifications and notify about the changes.
  gem 'listen', '~> 3.3'

  # Spring speeds up development by keeping your application running in the background.
  gem 'spring'
end
