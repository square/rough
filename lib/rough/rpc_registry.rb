require 'protobuf'

module Rough

  module RpcRegistry

    class << self

      def request_class_for(rpc_name)
        rpc_for(rpc_name).request_type
      end

      def response_class_for(rpc_name)
        rpc_for(rpc_name).response_type
      end

      private

      def rpc_for(rpc_name)
        return methods[rpc_name] if methods.key?(rpc_name)

        # TODO: in the future, should you be able to pass in a Rpc::Service, or separate rpc_name and method_names?
        service_name, method_name = rpc_name.split('#')

        service_class = service_name.constantize
        fail 'not a service class' unless service_class < Protobuf::Rpc::Service

        method = service_class.rpcs[method_name.to_sym]
        fail 'not a valid rpc' unless method

        methods[rpc_name] = method
      end

      def methods
        @methods ||= {}
      end

    end

  end

end
