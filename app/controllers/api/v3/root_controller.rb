module Api
  module V3
    class RootController < ApplicationController
      before_action :doorkeeper_authorize!, only: [:hello]

      def not_found
        raise ActiveRecord::RecordNotFound
      end

      def hello
        optional! :limit, values: 0..100

        render json: current_user, meta: { time: Time.now }
      end
    end
  end
end
