module Api
  module V3
    class UsersController < ApplicationController
      before_action :doorkeeper_authorize!, only: [:me, :follow, :unfollow, :block, :unblock, :blocked]
      before_action :set_user, except: [:index, :me]

      def index
        optional! :limit, default: 20, values: 1..100

        limit = params[:limit].to_i
        limit = 100 if limit > 100
        @users = User.fields_for_list.hot.limit(limit)
        render json: @users
      end

      def me
        render json: current_user, serializer: UserDetailSerializer
      end

      def show
        meta = { followed: false, blocked: false }

        if current_user
          meta[:followed] = current_user.followed?(@user)
          meta[:blocked] = current_user.blocked_user?(@user)
        end

        render json: @user, serializer: UserDetailSerializer, meta: meta
      end

      def topics
        optional! :order, type: String, default: 'recent', values: %w(recent likes replies)
        optional! :offset, type: Integer, default: 0
        optional! :limit, type: Integer, default: 20, values: 1..150

        @topics = @user.topics.fields_for_list
        if params[:order] == 'likes'
          @topics = @topics.high_likes
        elsif params[:order] == 'replies'
          @topics = @topics.high_replies
        else
          @topics = @topics.recent
        end
        @topics = @topics.includes(:user).offset(params[:offset]).limit(params[:limit])
        render json: @topics
      end

      def replies
        optional! :order, type: String, default: 'recent', values: %w(recent)
        optional! :offset, type: Integer, default: 0
        optional! :limit, type: Integer, default: 20, values: 1..150

        @replies = @user.replies.recent
        @replies = @replies.includes(:user, :topic).offset(params[:offset]).limit(params[:limit])

        render json: @replies, each_serializer: ReplyDetailSerializer
      end

      def favorites
        optional! :offset, type: Integer, default: 0
        optional! :limit, type: Integer, default: 20, values: 1..150

        @topic_ids = @user.favorite_topic_ids[params[:offset].to_i, params[:limit].to_i]
        @topics = Topic.where(id: @topic_ids).fields_for_list.includes(:user)
        @topics = @topics.to_a.sort do |a, b|
          @topic_ids.index(a.id) <=> @topic_ids.index(b.id)
        end
        render json: @topics
      end

      def followers
        optional! :offset, type: Integer, default: 0
        optional! :limit, type: Integer, default: 20, values: 1..150

        @users = @user.followers.fields_for_list.offset(params[:offset]).limit(params[:limit])
        render json: @users, root: 'followers'
      end

      def following
        optional! :offset, type: Integer, default: 0
        optional! :limit, type: Integer, default: 20, values: 1..150

        @users = @user.following.fields_for_list.offset(params[:offset]).limit(params[:limit])
        render json: @users, root: 'following'
      end

      def blocked
        optional! :offset, type: Integer, default: 0
        optional! :limit, type: Integer, default: 20, values: 1..150

        raise AccessDenied.new('不可以获取其他人的 blocked_users 列表。') if current_user.id != @user.id

        user_ids = current_user.blocked_user_ids[params[:offset].to_i, params[:limit].to_i]
        @blocked_users = User.where(id: user_ids)
        render json: @blocked_users, root: 'blocked'
      end

      def follow
        current_user.follow_user(@user)
        render json: { ok: 1 }, status: 201
      end

      def unfollow
        current_user.unfollow_user(@user)
        render json: { ok: 1 }, status: 201
      end

      def block
        current_user.block_user(@user.id)
        render json: { ok: 1 }, status: 201
      end

      def unblock
        current_user.unblock_user(@user.id)
        render json: { ok: 1 }, status: 201
      end


      private

      def set_user
        @user = User.find_login!(params[:id])
      end
    end
  end
end
