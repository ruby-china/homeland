module RubyChina
  module APIHelpers
    def warden
      env['warden']
    end
    
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
      token = params[:token] || oauth_token
      @current_user ||= User.where(private_token: token).first
    end
    
    def oauth_token
      # 此处的是为 ruby-china-for-ios 的 token Auth 特别设计的，不是所谓的 OAuth
      # 由于 NSRails 没有特别提供独立的 token 参数， 所以直接用 OAuth 那个参数来代替
      token = env['HTTP_AUTHORIZATION'] || ""
      token.split(" ").last
    end

    def authenticate!
      error!({ "error" => "401 Unauthorized" }, 401) unless current_user
    end
  end
end
