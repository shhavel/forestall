if ENV['RCOV'].to_s.downcase == 'true'
  require 'simplecov'
  require 'coveralls'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]
  SimpleCov.start do
    add_filter '/spec/'
    add_group 'Controllers', 'application'
    add_group 'Models', 'app/models'
    add_group 'Workers', 'app/workers'
  end
end

ENV['RACK_ENV'] = 'test'
require File.expand_path('../../application', __FILE__)

FactoryGirl.find_definitions

Sidekiq::Testing.inline!

Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Mongoid::Matchers, type: :model
  config.include FactoryGirl::Syntax::Methods
  config.default_formatter = 'doc' if config.files_to_run.one?

  def app
    Sinatra::Application
  end

  config.before(:each) do
    Session.delete_all
    Site.delete_all
    Script.delete_all
    SourceCode.delete_all
  end
end

require 'rspec_api_documentation/dsl'

RspecApiDocumentation.configure do |config|
  config.docs_dir = Pathname.new(Sinatra::Application.root).join('public')
  config.app = Sinatra::Application
  config.api_name = 'Forestall API'
  config.format = :html
  config.curl_host = 'http://localhost:9292' # https://forestall.example.com
  config.request_headers_to_include = %w(Content-Type Accept)
  config.curl_headers_to_filter = %w(Host Cookie)
end
