module RubyChina
  module APIHelpers
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

    # user helpers
    def current_user
      @current_user ||= ::User.where(:private_token => params[:token]).first
    end

    def authenticate!
      error!({ "error" => "401 Unauthorized" }, 401) unless current_user
    end
  end
end
