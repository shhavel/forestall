require 'bundler/setup'
Bundler.require :default, (ENV['RACK_ENV'] || :development).to_sym
puts "Loaded #{settings.environment} environment"

set :root, File.expand_path('..', File.dirname(__FILE__))
disable :show_exceptions
set :sockets, {}
settings.sockets.default_proc = proc { |hash, key| hash[key] = [] }

Mongoid.load!(File.join(settings.root, 'config', 'mongoid.yml'), settings.environment)
Dir[File.join(settings.root, 'app', '{models,workers}', '**', '*.rb')].each do |file|
  autoload File.basename(file, '.rb').camelize.to_sym, file
end
Dir[File.join(settings.root, 'config', 'initializers', '*.rb')].sort.each { |f| require f }

use Rack::PostBodyContentTypeParser
use Rack::Cors do
  allow do
    origins '*'
    resource '/*', headers: :any, methods: [:get, :options]
  end
end
use Rack::CommonLogger, $log_file

before do
  content_type :json
end
