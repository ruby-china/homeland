module Users
  module UserActions
    extend ActiveSupport::Concern

    included do
      before_action :authenticate_user!, only: [:block, :unblock, :blocked, :auth_unbind, :follow, :unfollow]
      before_action :only_user!, only: [:topics, :replies, :favorites, :notes,
                                        :auth_unbind, :block, :unblock, :follow, :unfollow,
                                        :followers, :following, :calendar]
    end

    def topics
      @topics = @user.topics.fields_for_list.recent.paginate(page: params[:page], per_page: 40)
      fresh_when([@topics])
    end

    def replies
      @replies = @user.replies.without_system.fields_for_list.recent.paginate(page: params[:page], per_page: 20)
      fresh_when([@replies])
    end

    def favorites
      @topic_ids = @user.favorite_topic_ids.reverse.paginate(page: params[:page], per_page: 40)
      @topics = Topic.where(id: @topic_ids).fields_for_list
      @topics = @topics.to_a.sort_by { |topic| @topic_ids.index(topic.id) }
      fresh_when([@topics])
    end

    def notes
      @notes = @user.notes.published.recent.paginate(page: params[:page], per_page: 40)
      fresh_when([@notes])
    end

    def auth_unbind
      provider = params[:provider]
      if current_user.authorizations.count <= 1
        redirect_to edit_user_registration_path, flash: { error: t('users.unbind_warning') }
        return
      end

      current_user.authorizations.where(provider: provider).delete_all
      redirect_to edit_user_registration_path, flash: { warring: t('users.unbind_success', provider: provider.titleize) }
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

      @blocked_users = User.where(id: current_user.blocked_user_ids).paginate(page: params[:page], per_page: 20)
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
      @users = @user.followers.fields_for_list.paginate(page: params[:page], per_page: 60)
      fresh_when([@users])
    end

    def following
      @users = @user.following.fields_for_list.paginate(page: params[:page], per_page: 60)
      render template: '/users/followers' if stale?(etag: [@users], template: 'users/followers')
    end

    def calendar
      data = @user.calendar_data
      render json: data if stale?(data)
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
