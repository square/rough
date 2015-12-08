Rails.application.routes.draw do
  post 'test-rpc' => 'test#test', rpc: 'Fake#fake'
  post 'test-not-rpc' => 'test#not_rpc'
end
