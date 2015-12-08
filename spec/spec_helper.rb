# Setup simplecov

require 'simplecov'
SimpleCov.start { add_filter('/spec/') }

# Setup combustion

require 'combustion'
Combustion.path = 'spec/dummy'
Combustion.initialize! :action_controller

# Load library

require 'rspec/rails'
require_relative '../lib/rough'

# For testing middleware

class MockRackApp

  attr_reader :env

  def call(env)
    @env = env
    [200, {}, ['OK']]
  end

end
