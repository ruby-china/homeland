module Api
  module V3
    class RootController < ApplicationController
      before_action :doorkeeper_authorize!, only: [:hello]

      # 简单的 API 测试接口，需要验证，便于快速测试 OAuth 以及其他 API 的基本格式是否正确
      def hello
        optional! :limit, values: 0..100

        render json: current_user, meta: { time: Time.now }
      end

      def not_found
        raise ActiveRecord::RecordNotFound
      end
    end
  end
end
