# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user_id

    def connect
      self.current_user_id = find_verified_user_id
    end

    protected

      def find_verified_user_id
        cookies.signed[:user_id] || nil
      end
  end
end
