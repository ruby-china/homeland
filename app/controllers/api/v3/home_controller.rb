module Api
  module V3
    class HomeController < Api::V3::ApplicationController
      before_action :doorkeeper_authorize!, only: [:check_in]

      def check_in
        if !current_user&.show_signin?
          render json: { success: false, message: "不能重复签到" }
        else
          Rails.cache.write("check_in:user_id#{current_user.id}", Time.current.strftime("%F"))
          current_user.change_score("signin")
          render json: { success: true }
        end
      end

      def show_check_in
        if current_user.nil?
          can_show = true
        else
          can_show = current_user.show_signin?
        end
        render json: { show: can_show }
      end
    end
  end
end
