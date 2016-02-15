module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user_id

    def connect
      self.current_user_id = find_verified_user_id
    end

    protected
      def find_verified_user_id
        if cookies.signed[:user_id].blank?
          reject_unauthorized_connection
          return nil
        end

        if current_user_id = cookies.signed[:user_id]
          current_user_id = current_user_id
        else
          reject_unauthorized_connection
        end
      end
  end
end
