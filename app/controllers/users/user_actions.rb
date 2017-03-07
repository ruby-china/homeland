module Users
  module UserActions
    extend ActiveSupport::Concern

    included do
      before_action :authenticate_user!, only: [:block, :unblock, :blocked, :follow, :unfollow]
      before_action :only_user!, only: [:topics, :replies, :favorites, :notes,
                                        :block, :unblock, :follow, :unfollow,
                                        :followers, :following, :calendar, :reward]
    end

    def topics
      @topics = @user.topics.fields_for_list.recent
      @topics = @topics.page(params[:page])
      fresh_when([@topics])
    end

    def replies
      @replies = @user.replies.without_system.fields_for_list.recent
      @replies = @replies.page(params[:page])
      fresh_when([@replies])
    end

    def favorites
      @topics = @user.favorite_topics.order('actions.id desc')
      @topics = @topics.page(params[:page])
      fresh_when([@topics])
    end

    def notes
      @notes = @user.notes.published.recent
      @notes = @notes.page(params[:page])
      fresh_when([@notes])
    end

    def block
      current_user.block_user(@user.id)
      render json: { code: 0 }
    end

    def unblock
      current_user.unblock_user(@user.id)
      render json: { code: 0 }
    end

    def blocked
      if current_user.id != @user.id
        render_404
      end

      @block_users = @user.block_users.order('actions.id asc').page(params[:page])
    end

    def follow
      current_user.follow_user(@user)
      render json: { code: 0, data: { followers_count: @user.followers_count } }
    end

    def unfollow
      current_user.unfollow_user(@user)
      render json: { code: 0, data: { followers_count: @user.followers_count } }
    end

    def followers
      @users = @user.follow_by_users.order('actions.id asc')
      @users = @users.page(params[:page]).per(60)
      fresh_when([@users])
    end

    def following
      @users = @user.follow_users.order('actions.id asc')
      @users = @users.page(params[:page]).per(60)
      render template: '/users/followers' if stale?(etag: [@users], template: 'users/followers')
    end

    def calendar
      data = @user.calendar_data
      render json: data if stale?(data)
    end

    def reward
    end

    private

    def only_user!
      render_404 if @user_type != :user
    end

    def user_show
      # 排除掉几个非技术的节点
      without_node_ids = [21, 22, 23, 31, 49, 51, 57, 25]
      @topics = @user.topics.fields_for_list.without_node_ids(without_node_ids).high_likes.limit(20)
      @replies = @user.replies.without_system.fields_for_list.recent.includes(:topic).limit(10)
      fresh_when([@topics, @replies])
    end
  end
end
