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

    def check_current_user_status_for_topic
    return false if not current_user
    
    # 找出用户 like 过的 Reply，给 JS 处理 like 功能的状态
    @user_liked_reply_ids = []
    # @replies.each { |r| @user_liked_reply_ids << r.id if r.liked_user_ids.index(current_user.id) != nil }
    # 通知处理
    current_user.read_topic(@topic)
    # 是否关注过
    @has_followed = @topic.follower_ids.index(current_user.id) == nil
    # 是否收藏
    @has_favorited = current_user.favorite_topic_ids.index(@topic.id) == nil
  end
  end
end
