# frozen_string_literal: true

module Users
  module UserActions
    extend ActiveSupport::Concern

    included do
      before_action :authenticate_user!, only: %i[block unblock blocked follow unfollow]
      before_action :only_user!, only: %i[topics replies favorites
        block unblock follow unfollow
        followers following reward]
    end

    def topics
      @topics = @user.topics.fields_for_list.recent
      @topics = @topics.page(params[:page])
    end

    def replies
      @replies = @user.replies.without_system.fields_for_list.recent
      @replies = @replies.page(params[:page])
    end

    def favorites
      @topics = @user.favorite_topics.order("actions.id desc")
      @topics = @topics.page(params[:page])
    end

    def block
      current_user.block_user(@user.id)
      render json: {code: 0}
    end

    def unblock
      current_user.unblock_user(@user.id)
      render json: {code: 0}
    end

    def blocked
      if current_user.id != @user.id
        render_404
      end

      @block_users = @user.block_users.order("actions.id asc").page(params[:page])
    end

    def follow
      current_user.follow_user(@user)
      render json: {code: 0, data: {followers_count: @user.reload.followers_count}}
    end

    def unfollow
      current_user.unfollow_user(@user)
      render json: {code: 0, data: {followers_count: @user.reload.followers_count}}
    end

    def followers
      @users = @user.follow_by_users.order("actions.id asc")
      @users = @users.page(params[:page]).per(60)
    end

    def following
      @users = @user.follow_users.order("actions.id asc")
      @users = @users.page(params[:page]).per(60)
      render template: "/users/followers"
    end

    def reward
    end

    private

    def only_user!
      render_404 if @user_type != :user
    end

    def user_show
      @topics = @user.topics.fields_for_list.high_likes.page(params[:page])
      @replies = @user.replies.without_system.fields_for_list.recent.includes(:topic).limit(10)
    end
  end
end
