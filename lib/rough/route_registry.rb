require_relative 'route'
require_relative 'invalid_route'

module Rough

  module RouteRegistry

    class << self

      def rpc_route_for(service_name, method_name)
        return cached_routes[service_name][method_name] if cached_routes[service_name].key?(method_name)
        route = find_route(service_name, method_name)
        cached_routes[service_name][method_name] = route ? Route.new(route) : nil
      end

      # Warm up cache for each defined RPC route
      def warm!
        rpc_driven_routes.each do |route|
          service_name, method_name = route.defaults[:rpc].split('#')

          # java-ize service name
          service_segments = service_name.split('::')
          final_service_name = service_segments.pop
          service_name = (service_segments.map(&:underscore) << final_service_name).join('.')

          # java-ize method name
          method_name = method_name.camelize

          cached_routes[service_name][method_name] = Route.new(route)
        end
      end

      private

      def cached_routes
        @cached_routes ||= Hash.new { |h, k| h[k] = {} }
      end

      # find a particular rails route for a given service_name and method_name
      def find_route(matched_service_name, matched_method_name)
        rpc_driven_routes.find do |route|
          service_name, method_name = route.defaults[:rpc].split('#')

          # ruby-ize service name
          matched_service_segments = matched_service_name.split('.')
          final_service_name = matched_service_segments.pop
          matched_service_name = (matched_service_segments.map(&:capitalize) << final_service_name).join('::')

          # ruby-ize method name
          matched_method_name = matched_method_name.underscore

          # does it match
          matched_service_name == service_name && matched_method_name == method_name
        end
      end

      def rpc_driven_routes
        Rails.application.routes.routes.lazy.select do |route|
          route.defaults && route.defaults[:rpc]
        end
      end

    end

  end

end
