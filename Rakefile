require File.dirname(__FILE__) + '/lib/rough/version'


begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task default: :spec
rescue LoadError
  # no rspec available
end

task build: :default do
  system 'gem build rough.gemspec'
end
