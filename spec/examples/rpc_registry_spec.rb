require 'spec_helper'

describe Rough::RpcRegistry do

  class ListRequest;  end
  class ListResponse; end

  class JohnService < Protobuf::Rpc::Service
    rpc :list, ListRequest, ListResponse
  end

  shared_examples 'rpc_lookup' do

    context 'when the service class does not exist' do

      let(:rpc_name) { 'SomethingFake#fake' }

      it 'should raise a NameError' do
        expect { subject }.to raise_error(NameError)
      end

    end

    context 'when the service class has the wrong superclass' do

      let(:rpc_name) { 'String#reverse' }

      it 'should raise a RuntimeError' do
        expect { subject }.to raise_error(RuntimeError, 'not a service class')
      end

    end

    context 'when the service class is a valid service' do

      context 'and the method struct does not exist on the service' do

        let(:rpc_name) { 'JohnService#fake' }

        it 'should raise a RuntimeError' do
          expect { subject }.to raise_error(RuntimeError, 'not a valid rpc')
        end

      end

      context 'and the method struct exists on the service' do

        let(:rpc_name) { 'JohnService#list' }

        it 'should return the proper method struct' do
          expect(subject).to eq(request ? ListRequest : ListResponse)
        end

        context 'when accessing a second time' do

          it 'should use a cached copy' do
            expect(JohnService).not_to receive(:<)
            expect(subject).to eq(request ? ListRequest : ListResponse)
          end

        end

      end

    end

  end

  describe '#request_class_for' do

    subject { Rough::RpcRegistry.request_class_for(rpc_name) }
    let(:request) { true }

    it_should_behave_like 'rpc_lookup'

  end

  describe '#response_class_for' do

    subject { Rough::RpcRegistry.response_class_for(rpc_name) }
    let(:request) { false }

    it_should_behave_like 'rpc_lookup'

  end

end
