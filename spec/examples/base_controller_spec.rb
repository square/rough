require 'spec_helper'
require 'action_controller'

# Rough::BaseController is included in TestController
describe TestController, type: :request do

  class FakeRequestProto < Protobuf::Message
    optional :string, :name, 1
  end

  class FakeResponseProto < Protobuf::Message
  end

  let(:request_klass)  { FakeRequestProto }
  let(:response_klass) { FakeResponseProto }

  before do
    allow(Rough::RpcRegistry).to receive(:request_class_for).with('Fake#fake').and_return(request_klass)
    allow(Rough::RpcRegistry).to receive(:response_class_for).with('Fake#fake').and_return(response_klass)
  end

  context 'when the route is rpc' do

    context 'and called over form-data' do

      before do
        allow(Rails.logger).to receive(:info)
        post '/test-rpc', name: 'john'
      end

      it 'should pass back the response status' do
        expect(response.status).to eq(TestController::STATUS)
      end

      it 'should log the request proto' do
        rp = FakeRequestProto.new({ name: 'john', rpc: 'Fake#fake', action: 'test', controller: 'test' }.stringify_keys)
        expect(Rails.logger).to have_received(:info).with("  Request Proto: #{rp.inspect}")
      end

      it 'should respond with json' do
        expect(response.content_type).to eq('application/json')
      end

    end

    context 'and called over json' do

      before do
        allow(Rails.logger).to receive(:info)
        post '/test-rpc', {
          name: 'john'
        }.to_json, 'Content-Type' => 'application/json', 'Accept' => 'application/json'
      end

      it 'should pass back the response status' do
        expect(response.status).to eq(TestController::STATUS)
      end

      it 'should log the request proto' do
        rp = FakeRequestProto.new({ name: 'john', rpc: 'Fake#fake', action: 'test', controller: 'test' }.stringify_keys)
        expect(Rails.logger).to have_received(:info).with("  Request Proto: #{rp.inspect}")
      end

      it 'should respond with json' do
        expect(response.content_type).to eq('application/json')
      end

    end

    context 'and called over proto' do

      let(:echo_request) { FakeRequestProto.new(name: 'john') }
      let(:echo_response) { FakeResponseProto.new(name: 'john') }
      let(:mime) { Rough::BaseController::PROTO_MIME.to_s }

      before do
        allow(Rails.logger).to receive(:info)
        post '/test-rpc', echo_request.encode, 'Content-Type' => mime, 'Accept' => mime
      end

      it 'should pass back the underlying status' do
        expect(response.status).to eq(400)
      end

      it 'should return the encoding' do
        expect(response.body).to eq(echo_response.encode)
      end

      it 'should respond with proto' do
        expect(response.content_type).to eq(mime)
      end

      it 'should not set a charset in the Content-Type header' do
        expect(response['Content-Type']).to eq(mime)
      end

      it 'should make the request_proto accessible in before_actions' do
        expect(assigns(:test_request_proto).name).to eql 'john'
      end

      it 'should make the response_proto accessible in before_actions' do
        expect(assigns(:test_response_proto)).to be_an_instance_of FakeResponseProto
      end
    end

    context 'when there is a type error while decoding' do

      before do
        allow(FakeRequestProto).to receive(:new).and_raise(TypeError)
      end

      it 'should raise InvalidRequestProto' do
        expect { post '/test-rpc' }.to raise_error(Rough::InvalidRequestProto)
      end

    end

  end

  context 'when the route is not rpc' do

    before do
      allow(Rails.logger).to receive(:info)
      post '/test-not-rpc', name: 'john'
    end

    it 'should pass back the response status' do
      expect(response.status).to eq(TestController::STATUS)
    end

    it 'should not log the request proto' do
      rp = OpenStruct.new(name: 'john', rpc: 'Fake#fake', action: 'test', controller: 'test')
      expect(Rails.logger).not_to have_received(:info).with("  Request Proto: #{rp.inspect}")
    end

  end

end
