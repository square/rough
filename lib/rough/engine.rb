require_relative 'middleware'
require_relative 'base_controller'
require 'rails/engine'

module Rough

  class Engine < Rails::Engine

    initializer 'rough_engine.middleware' do |app|
      app.middleware.insert_after ActionDispatch::ParamsParser, Rough::Middleware
    end

  end

end
