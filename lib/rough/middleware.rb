require_relative 'route_registry'

module Rough

  class Middleware

    # This is the format for the service routes.  It is expected to capture
    # service_name and method_name (as named regex matches) from the given URL.
    ROUTE_FORMAT = %r{^/services/(?<service_name>.+)/(?<method_name>.+)$}

    def initialize(app)
      @app = app
    end

    def call(env)
      path = env['PATH_INFO']
      if env['REQUEST_METHOD'] == 'POST'
        match = path.match(ROUTE_FORMAT)
        if match
          # re-map this route if we detect a matching RPC
          rpc_route = RouteRegistry.rpc_route_for(match[:service_name], match[:method_name])
          if rpc_route
            env['PATH_INFO'] = rpc_route.path
            env['REQUEST_METHOD'] = rpc_route.request_method
            env['HTTP_ACCEPT'] = 'application/x-protobuf'
            env['HTTP_CONTENT_TYPE'] = 'application/x-protobuf'
          end
        end
      end
      @app.call(env)
    end

  end

end
