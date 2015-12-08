require_relative 'invalid_route'

module Rough

  class Route

    attr_reader :route

    def initialize(route)
      @route = route
    end

    def path
      @path ||= load_path
    end

    def request_method
      @request_method ||= load_request_method
    end

    private

    def load_request_method
      method_rule = @route.constraints[:request_method]
      methods = ActionDispatch::Request::RFC2616.select { |t| t =~ method_rule }
      methods.count == 1 ? methods.first : fail(InvalidRoute)
    end

    def load_path
      fake_defaults = @route.defaults.dup
      fake_defaults[:only_path] = true
      @route.segments.each { |s| fake_defaults[s.to_sym] = s }
      path = Rails.application.routes.url_for(fake_defaults)
      path || fail(InvalidRoute)
    end

  end

end
