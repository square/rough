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
        return method_structs[rpc_name] if method_structs.key?(rpc_name)

        # TODO: in the future, should you be able to pass in a Rpc::Service, or separate rpc_name and method_names?
        service_name, method_name = rpc_name.split('#')

        service_class = service_name.constantize
        fail 'not a service class' unless service_class < Protobuf::Rpc::Service

        method_struct = service_class.rpcs[method_name.to_sym]
        fail 'not a valid rpc' unless method_struct.is_a?(Struct::RpcMethod)

        method_structs[rpc_name] = method_struct
      end

      def method_structs
        @method_structs ||= {}
      end

    end

  end

end
