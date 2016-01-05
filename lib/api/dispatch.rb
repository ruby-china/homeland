module API
  class Dispatch < Grape::API
    use ActionDispatch::RemoteIp

    mount API::V3::Root

    format :json
    content_type :json, 'application/json;charset=utf-8'

    route :any, '*path' do
      status 404
      { error: 'Page not found.' }
    end
  end
end
