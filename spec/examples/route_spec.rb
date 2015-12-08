require 'spec_helper'

describe Rough::Route do

  let(:routeset) { OpenStruct.new }
  let(:defaults) { { hello: 'world' } }
  let(:underlying_route) { OpenStruct.new(defaults: defaults, segments: []) }
  let(:route) { Rough::Route.new(underlying_route) }

  before do
    application = OpenStruct.new(routes: routeset)
    allow(Rails).to receive(:application).and_return(application)
  end

  describe '#path' do

    before do
      expected_argument = underlying_route.defaults.merge(only_path: true)
      allow(routeset).to receive(:url_for).with(expected_argument).and_return(path)
    end

    context 'when there is a route' do

      let(:path) { SecureRandom.uuid }

      it 'should get the route from rails' do
        expect(route.path).to eq(path)
      end

    end

    context 'when there is no route' do

      let(:path) { nil }

      it 'should raise invalid route' do
        expect { route.path }.to raise_error(Rough::InvalidRoute)
      end

    end

  end

  describe '#request_method' do

    before do
      allow(underlying_route).to receive(:constraints).and_return(
        request_method: request_method
      )
    end

    context 'when there is a single matching request method' do

      let(:request_method) { /^GET$/ }

      it 'should return the request method' do
        expect(route.request_method).to eq('GET')
      end

    end

    context 'when there are more than one matching request methods' do

      let(:request_method) { /^GET|POST$/ }

      it 'should raise InvalidRoute' do
        expect { route.request_method }.to raise_error(Rough::InvalidRoute)
      end

    end

  end

end
