# frozen_string_literal: true

module Api
  module V3
    class UsersController < Api::V3::ApplicationController
      before_action :doorkeeper_authorize!, only: %i[me follow unfollow block unblock blocked]
      before_action :set_user, except: %i[index me]

      # 获取热门用户
      #
      # GET /api/v3/users
      #
      # @param limit [Integer] default: 20，range: 1..100
      # @return [Array<UserSerializer>]
      def index
        optional! :limit, default: 20, values: 1..100

        limit = params[:limit].to_i
        limit = 100 if limit > 100
        @users = User.fields_for_list.hot.limit(limit)
      end

      # 获取当前用户的完整信息，用于个人设置修改资料
      #
      # GET /api/v3/users/me
      def me
        @user = current_user
        render "show"
      end

      # 获取某个用户的详细信息
      #
      # GET /api/v3/users/:id
      # @return [UserDetailSerializer]
      def show
        @meta = { followed: false, blocked: false }

        if current_user
          @meta[:followed] = current_user.follow_user?(@user)
          @meta[:blocked] = current_user.block_user?(@user)
        end
      end

      # 获取某个用户的话题列表
      #
      # GET /api/v3/users/:id/topics
      #
      # @param order [String] 排序方式, default: 'recent', range: %w(recent likes replies)
      # @param offset [Integer] default: 0
      # @param limit [Integer] default: 20, range: 1..150
      #
      # @return [Array<TopicSerializer>] 话题列表
      def topics
        optional! :order, type: String, default: "recent", values: %w[recent likes replies]
        optional! :offset, type: Integer, default: 0
        optional! :limit, type: Integer, default: 20, values: 1..150

        @topics = @user.topics.fields_for_list
        @topics =
          if params[:order] == "likes"
            @topics.high_likes
          elsif params[:order] == "replies"
            @topics.high_replies
          else
            @topics.recent
          end
        @topics = @topics.includes(:user).offset(params[:offset]).limit(params[:limit])
      end

      # 获取某个用户的回帖列表
      #
      # GET /api/v3/users/:id/replies
      # == params:
      #
      # @param order [String] 排序方式, default: 'recent', range: %w(recent)
      # @param offset [Integer] default: 0
      # @param limit [Integer] default: 20, range: 1..150
      #
      # @return [Array<ReplyDetailSerializer>]
      def replies
        optional! :order, type: String, default: "recent", values: %w[recent]
        optional! :offset, type: Integer, default: 0
        optional! :limit, type: Integer, default: 20, values: 1..150

        @replies = @user.replies.recent
        @replies = @replies.includes(:user, :topic).offset(params[:offset]).limit(params[:limit])

        @replies = @replies.map do |r|
          if not r.exposed_to_author_only? || (current_user && (r.topic && r.topic.user == current_user || r.user == current_user))
            r
          else
            r.body = I18n.t("topics.exposed_to_author_only")
            r
          end
        end
      end

      # 获取某个用户的收藏列表
      #
      # GET /api/v3/users/:id/favorites
      #
      # @param offset [Integer] default: 0
      # @param limit [Integer] default: 20, range: 1..150
      # @return <Array[TopicSerializer]> 收藏的话题列表
      def favorites
        optional! :offset, type: Integer, default: 0
        optional! :limit, type: Integer, default: 20, values: 1..150

        @topics = @user.favorite_topics.includes(:user).order("actions.id desc").offset(params[:offset]).limit(params[:limit])
        render "topics"
      end

      # 获取某个用户关注的人的列表
      #
      # GET /api/v3/users/:id/followers
      #
      # @param offset [Integer] default: 0
      # @param limit [Integer] default: 20, range: 1..150
      # @return <Array[UserSerializer]> 用户列表
      def followers
        optional! :offset, type: Integer, default: 0
        optional! :limit, type: Integer, default: 20, values: 1..150

        @users = @user.follow_by_users.fields_for_list.order("actions.id asc").offset(params[:offset]).limit(params[:limit])
      end

      # 获取某个用户的关注者列表
      #
      # GET /api/v3/users/:id/following
      #
      # @param (see #followers)
      # @return (see #followers)
      def following
        optional! :offset, type: Integer, default: 0
        optional! :limit, type: Integer, default: 20, values: 1..150

        @users = @user.follow_users.fields_for_list.order("actions.id asc").offset(params[:offset]).limit(params[:limit])
      end

      # 获取用户的已屏蔽的人（只能获取自己的）
      #
      # GET /api/v3/users/:id/blocked
      #
      # @param (see #followers)
      # @return (see #followers)
      def blocked
        optional! :offset, type: Integer, default: 0
        optional! :limit, type: Integer, default: 20, values: 1..150

        raise AccessDenied.new("不可以获取其他人的 block_users 列表。") if current_user.id != @user.id

        @users = current_user.block_users.fields_for_list.order("actions.id asc").offset(params[:offset]).limit(params[:limit])
      end

      # 关注用户
      #
      # POST /api/v3/users/:id/follow
      def follow
        current_user.follow_user(@user)
        render json: { ok: 1 }
      end

      # 取消关注用户
      #
      # POST /api/v3/users/:id/unfollow
      def unfollow
        current_user.unfollow_user(@user)
        render json: { ok: 1 }
      end

      # 屏蔽用户
      #
      # POST /api/v3/users/:id/block
      def block
        current_user.block_user(@user.id)
        render json: { ok: 1 }
      end

      # 取消屏蔽用户
      #
      # POST /api/v3/users/:id/unblock
      def unblock
        current_user.unblock_user(@user.id)
        render json: { ok: 1 }
      end

      private

        def set_user
          @user = User.find_by_login!(params[:id])
        end
    end
  end
end
