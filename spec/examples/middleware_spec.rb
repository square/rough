require 'spec_helper'

describe Rough::Middleware do

  let(:app) { MockRackApp.new }
  let(:request) { Rack::MockRequest.new(subject) }
  let(:env) { app.env }

  subject { described_class.new(app) }

  shared_examples_for 'a pass-through middleware' do
    before do
      request.send(request_method, path)
    end

    it 'should not modify the path' do
      expect(env['PATH_INFO']).to eq(path)
    end

    it 'should not modify the request method' do
      expect(env['REQUEST_METHOD']).to eq(request_method.to_s.upcase)
    end
  end

  context 'when calling a route other than the services route' do
    let(:request_method) { :get }
    let(:path) { '/hello' }

    it_should_behave_like 'a pass-through middleware'
  end

  context 'when calling the services route' do

    let(:route_details) do
      OpenStruct.new(
        request_method: 'GET',
        path: '/users'
      )
    end

    before do
      allow(Rough::RouteRegistry).to receive(:rpc_route_for).with('JohnService', 'real').and_return(route_details)
      allow(Rough::RouteRegistry).to receive(:rpc_route_for).with('JohnService', 'fake').and_return(nil)
    end

    context 'when using POST' do

      context 'when the route exists in the RPC registry' do
        before do
          request.post('/services/JohnService/real')
        end

        it 'should modify the path' do
          expect(env['PATH_INFO']).to eq(route_details.path)
        end

        it 'should modify the request method' do
          expect(env['REQUEST_METHOD']).to eq(route_details.request_method)
        end

        it 'should modify the accept header' do
          expect(env['HTTP_ACCEPT']).to eq('application/x-protobuf')
        end

        it 'should modify the content-type header' do
          expect(env['HTTP_CONTENT_TYPE']).to eq('application/x-protobuf')
        end
      end

      context 'when the route does not exist in the RPC registry' do
        let(:fake_service_url) { '/services/JohnService/fake' }

        before { request.post(fake_service_url) }

        it 'should proceed to the rails router unchanged' do
          expect(env['PATH_INFO']).to eq(fake_service_url)
        end
      end

    end

    context 'when using GET' do
      let(:request_method) { :get }
      let(:path) { '/services/JohnService/hello' }

      it_should_behave_like 'a pass-through middleware'
    end

  end

end
