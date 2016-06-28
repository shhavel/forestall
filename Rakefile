require_relative 'application'

unless ENV['RACK_ENV'].to_s == 'production'
  require 'rspec_api_documentation'
  load 'tasks/docs.rake'

  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:test) do |t|
    t.rspec_opts = ['-c', '-f documentation', '-r ./spec/spec_helper.rb']
    t.pattern = 'spec/**/*_spec.rb'
  end
  task default: :test
end
