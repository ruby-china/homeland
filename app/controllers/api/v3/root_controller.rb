module Api
  module V3
    class RootController < Api::V3::ApplicationController
      before_action :doorkeeper_authorize!, only: [:hello]

      def not_found
        raise ActiveRecord::RecordNotFound
      end

      # 简单的 API 测试接口，需要验证，便于快速测试 OAuth 以及其他 API 的基本格式是否正确
      #
      # GET /api/v3/hello
      #
      # @param limit - API token
      # @return [UserDetailSerializer]
      def hello
        optional! :limit, values: 0..100

        @meta = { time: Time.now }
        @user = current_user

        render "api/v3/users/show"
      end
    end
  end
end
