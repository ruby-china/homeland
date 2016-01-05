module API
  require 'doorkeeper/grape/helpers'

  module V3
    class Root < Grape::API
      version 'v3'

      default_error_formatter :json
      content_type :json, 'application/json'
      format :json
      formatter :json, Grape::Formatter::ActiveModelSerializers

      rescue_from :all do |e|
        case e
        when Mongoid::Errors::DocumentNotFound
          Rack::Response.new([{ error: '数据不存在' }.to_json], 404, {}).finish
        when Grape::Exceptions::ValidationErrors
          Rack::Response.new([{
            error: '参数不符合要求，请检查参数是否按照 API 要求传输。',
            validation_errors: e.errors
          }.to_json], 400, {}).finish
        else
          # ExceptionNotifier.notify_exception(e) # Uncommit it when ExceptionNotification is available
          if Rails.env.test?
            Rails.logger.error "Error: #{e}\n#{e.backtrace[0, 3].join("\n")}"
          else
            Rails.logger.error "Api V3 Error: #{e}\n#{e.backtrace.join("\n")}"
          end
          Rack::Response.new([{ error: 'API 接口异常' }.to_json], 500, {}).finish
        end
      end

      helpers Doorkeeper::Grape::Helpers
      helpers API::V3::Helpers

      mount API::V3::Topics
      mount API::V3::Replies
      mount API::V3::Users
      mount API::V3::Notifications
      mount API::V3::Likes

      desc %(简单的 API 测试接口，需要验证，便于快速测试 OAuth 以及其他 API 的基本格式是否正确
  ### Returns:

  ```json
  {
      "user": {
          "id": 2,
          "login": "huacnlee",
          "name": "李华顺",
          "avatar_url": "http://ruby-china-files-dev.b0.upaiyun.com/user/large_avatar/2.jpg"
      },
      "meta": {
          "time": "2015-05-18T23:06:49.874+08:00"
      }
  }
  ```)
      params do
        optional :limit, type: Integer, values: 0..100
      end
      get 'hello' do
        doorkeeper_authorize!
        render current_user, meta: { time: Time.now }
      end

      resource :nodes do
        # Get a list of all nodes
        desc <<~DESC
        获取所有节点列表

        ### Returns:

        ```json
        {
            "nodes": [
                {
                    "id": 1,
                    "name": "Ruby",
                    "topics_count": 1692,
                    "summary": "Ruby 是一门优美的语言",
                    "section_id": 1,
                    "sort": 0,
                    "section_name": "Ruby",
                    "updated_at": "2015-03-01T22:35:21.627+08:00"
                },
                {
                    "id": 2,
                    "name": "Rails",
                    "topics_count": 3160,
                    "summary": "Ruby on Rails, 也称 Rails, 是一个使用 Ruby 语言写的开源 Web 开发框架。",
                    "section_id": 1,
                    "sort": 98,
                    "section_name": "Ruby",
                    "updated_at": "2015-03-01T22:35:21.657+08:00"
                },
                ...
            ]
        }
        ```
        DESC
        get do
          nodes = Node.includes(:section).all
          render nodes, meta: { total: Node.count }
        end

        desc <<~DESC
        获取单个 Node 的详情，结构类似 /api/v3/nodes.json 里面 Hash 的结构

        此接口的使用场景：

        需要获取单个 Node 的话题总数，介绍等信息的时候，你无须再拉取 Node 列表。
        DESC
        get ':id' do
          node = Node.find(params[:id])
          render node
        end
      end

      resource :photos do
        before do
          doorkeeper_authorize!
        end

        desc '上传图片,请使用 Multipart 的方式提交图片文件'
        params do
          requires :file, desc: 'Image file.'
        end
        post do
          @photo = Photo.new
          @photo.image = params[:file]
          @photo.user_id = current_user.id
          if @photo.save
            { image_url: @photo.image.url }
          else
            error!({ error: @photo.errors.full_messages }, 400)
          end
        end
      end
    end
  end
end
