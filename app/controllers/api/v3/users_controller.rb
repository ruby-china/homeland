module Api
  module V3
    class UsersController < Api::V3::ApplicationController
      before_action :doorkeeper_authorize!, only: [:me, :follow, :unfollow, :block, :unblock, :blocked]
      before_action :set_user, except: [:index, :me]

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
        render json: @users
      end

      # 获取当前用户的完整信息，用于个人设置修改资料
      #
      # GET /api/v3/users/me
      # @return [UserDetailSerializer]
      def me
        render json: current_user, serializer: UserDetailSerializer
      end

      # 获取某个用户的详细信息
      #
      # GET /api/v3/users/:id
      # @return [UserDetailSerializer]
      def show
        meta = { followed: false, blocked: false }

        if current_user
          meta[:followed] = current_user.followed?(@user)
          meta[:blocked] = current_user.blocked_user?(@user)
        end

        render json: @user, serializer: UserDetailSerializer, meta: meta
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
        optional! :order, type: String, default: 'recent', values: %w(recent likes replies)
        optional! :offset, type: Integer, default: 0
        optional! :limit, type: Integer, default: 20, values: 1..150

        @topics = @user.topics.fields_for_list
        @topics =
          if params[:order] == 'likes'
            @topics.high_likes
          elsif params[:order] == 'replies'
            @topics.high_replies
          else
            @topics.recent
          end
        @topics = @topics.includes(:user).offset(params[:offset]).limit(params[:limit])
        render json: @topics
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
        optional! :order, type: String, default: 'recent', values: %w(recent)
        optional! :offset, type: Integer, default: 0
        optional! :limit, type: Integer, default: 20, values: 1..150

        @replies = @user.replies.recent
        @replies = @replies.includes(:user, :topic).offset(params[:offset]).limit(params[:limit])

        render json: @replies, each_serializer: ReplyDetailSerializer
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

        @topic_ids = @user.favorite_topic_ids.reverse[params[:offset].to_i, params[:limit].to_i]
        @topics = Topic.where(id: @topic_ids).fields_for_list.includes(:user)
        @topics = @topics.to_a.sort_by { |topic| @topic_ids.index(topic.id) }
        render json: @topics
      end

      # 获取某个用户关注的人的列表
      #
      # GET /api/v3/users/:id/followers
      #
      # @param offset [Integer] default: 0
      # @param limit [Integer] default: 20, range: 1..150
      # @return <Array[UserSerializer]> 收藏的话题列表
      def followers
        optional! :offset, type: Integer, default: 0
        optional! :limit, type: Integer, default: 20, values: 1..150

        @users = @user.followers.fields_for_list.offset(params[:offset]).limit(params[:limit])
        render json: @users, root: 'followers'
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

        @users = @user.following.fields_for_list.offset(params[:offset]).limit(params[:limit])
        render json: @users, root: 'following'
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

        raise AccessDenied.new('不可以获取其他人的 blocked_users 列表。') if current_user.id != @user.id

        user_ids = current_user.blocked_user_ids[params[:offset].to_i, params[:limit].to_i]
        @blocked_users = User.where(id: user_ids)
        render json: @blocked_users, root: 'blocked'
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
