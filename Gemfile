# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.0'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 4.3'

gem 'gemoji'

gem 'graphql'
gem 'graphql-batch'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

gem 'sorbet-rails'
gem 'sorbet-runtime'

# TrueSkill
gem 'trueskill', github: 'saulabs/trueskill', require: 'saulabs/trueskill'

# Handle CORS
gem 'rack-cors'

gem 'terminal-table'

gem 'httparty'

group :development, :test do
  gem 'awesome_print'
  gem 'byebug'
  gem 'factory_bot_rails'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'webmock'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console'
  # anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'bullet'
  gem 'rubocop', require: false
end
