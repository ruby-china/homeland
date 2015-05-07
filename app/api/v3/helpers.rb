module V3
  module Helpers    
    # topic helpers
    def max_page_size
      100
    end

    def default_page_size
      15
    end

    def page_size
      size = params[:size].to_i
      [size.zero? ? default_page_size : size, max_page_size].min
    end
    
    def access_token
      @_doorkeeper_token
    end

    # user helpers
    def current_user
      @current_user ||= User.find_by_id(access_token.resource_owner_id) if access_token
    end

    def authenticate!
      error!({ "error" => "401 Unauthorized" }, 401) unless current_user
    end
  end
end
