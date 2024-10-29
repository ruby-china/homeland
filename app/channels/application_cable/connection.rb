module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user_id

    def connect
      self.current_user_id = find_verified_user
    end

    def disconnect
      logger.info "Active Connections: #{ActionCable.server.connections.length}"
    end

    protected

    def find_verified_user
      cookies.signed[:user_id] || reject_unauthorized_connection
    end
  end
end
