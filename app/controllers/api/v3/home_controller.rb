module Api
  module V3
    class HomeController < Api::V3::ApplicationController
      before_action :doorkeeper_authorize!, only: [:check_in, :show_check_in]

      def check_in
        Rails.cache.write("check_in:user_id#{current_user.id}", Time.current.strftime("%F"))
        current_user.change_score("signin")
        render json: { success: true }
      end

      def show_check_in
        render json: { show: current_user.show_signin? }
      end
    end
  end
end
