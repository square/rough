class TestController < ActionController::Base

  STATUS = 400

  before_action do
    @test_request_proto = request_proto
    @test_response_proto = response_proto
  end

  include Rough::BaseController

  def test
    render json: params.to_json, status: STATUS
  end

  def not_rpc
    render json: params.to_json, status: STATUS
  end

end
