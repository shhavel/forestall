source 'https://rubygems.org'

gem 'sinatra'
gem 'sinatra-param'
gem 'rack-contrib', git: 'https://github.com/rack/rack-contrib'
gem 'rack-cors', require: 'rack/cors'
gem 'rake'
gem 'activesupport', require: 'active_support'
gem 'mongoid'
gem 'pry', require: false

group :development, :test do
  gem 'thin'
  gem 'pry-byebug'
  gem 'rspec_api_documentation'
  gem 'railroady'
end

group :test do
  gem 'rspec'
  gem 'rack-test'
  gem 'mongoid-rspec'
  gem 'factory_girl'
  gem 'simplecov', require: false
  gem 'coveralls', require: false
end
