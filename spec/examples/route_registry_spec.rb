require 'spec_helper'

describe Rough::RouteRegistry do

  describe '#rpc_route_for' do

    let(:real_route) do
      defaults = { rpc: 'Some::Real::ServiceClass#thing_you_love' }
      OpenStruct.new(defaults: defaults)
    end

    before do
      routeset = ActionDispatch::Routing::RouteSet.new
      allow(routeset).to receive(:routes).and_return([real_route])
      allow(Rails).to receive(:application).and_return(OpenStruct.new(routes: routeset))
    end

    let(:found_route) do
      Rough::RouteRegistry.rpc_route_for(service_name, method_name)
    end

    let(:service_name) { 'some.real.ServiceClass' }
    let(:method_name) { 'ThingYouLove' }

    context 'when there is no matching route' do

      let(:service_name) { 'Something' }
      let(:method_name)  { 'fake' }

      it 'should return nil' do
        expect(found_route).to be_nil
      end

    end

    context 'when the cache has been warmed' do

      before { Rough::RouteRegistry.warm! }

      it 'should have entries in the cached routes' do
        expect(Rough::Route).not_to receive(:new)
        expect(found_route.route).to eq(real_route)
      end

    end

    context 'when there is a valid route' do

      before do
        Rough::RouteRegistry.instance_variable_set(:@cached_routes, nil) # clear cache
        found_route # use route
      end

      it 'should return that route encased in a Rough::Route' do
        expect(found_route.route).to eq(real_route)
      end

      context 'when asking for the route again' do

        it 'should use a cached copy' do
          expect(Rough::Route).not_to receive(:new)
          expect(found_route.route).to eq(real_route)
        end

      end

    end

  end

end
