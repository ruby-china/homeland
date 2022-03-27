# frozen_string_literal: true

module Api
  module V3
    class TopicsController < Api::V3::ApplicationController
      before_action :doorkeeper_authorize!, except: %i[index show replies]
      before_action :set_topic, except: %i[index create]

      # Get Topic List, like /topics page.
      #
      # GET /api/v3/topics
      #
      # @param type [String] order type, default: `last_actived`, %w(last_actived recent no_reply popular excellent)
      # @param node_id [Integer] Node ID, if present, will filter with node.
      # @param offset [Integer] default: 0
      # @param limit [Integer] default: 20, range: 1..150
      #
      # @return [Array<TopicSerializer>]
      def index
        optional! :type, default: "last_actived"
        optional! :node_id
        optional! :offset, default: 0
        optional! :limit, default: 20, values: 1..150

        params[:type] = params[:type].downcase

        if params[:node_id].blank?
          @topics = Topic
          if current_user
            @topics = @topics.without_nodes(current_user.block_node_ids)
            @topics = @topics.without_users(current_user.block_user_ids)
          else
            @topics = @topics.without_hide_nodes
          end
        else
          @node = Node.find(params[:node_id])
          @topics = @node.topics
        end

        current_user&.touch_last_online_ts

        @topics = @topics.without_ban.fields_for_list.includes(:node, :user).send(scope_method_by_type)
        if %w[no_reply popular].index(params[:type])
          @topics = @topics.last_actived
        elsif params[:type] == "excellent"
          @topics = @topics.recent
        end

        @topics = @topics.offset(params[:offset]).limit(params[:limit])
      end

      # Get Topic Detail (not including replies)
      #
      # GET /api/v3/topics/:id
      #
      # @param id [Integer] Topic ID
      # @return [TopicDetailSerializer] In addition, meta contains the status of the current user on this topic.
      #
      # ```json
      # { followed: 'Is followed this Topic', liked: 'Is liked this Topic', favorited: 'Is favorited this Topic' }
      # ```
      def show
        @meta = {followed: false, liked: false, favorited: false}

        if current_user
          current_user.touch_last_online_ts
          # Create Notifications
          current_user.read_topic(@topic)
          @meta[:followed] = current_user.follow_topic?(@topic)
          @meta[:liked] = current_user.like_topic?(@topic)
          @meta[:favorited] = current_user.favorite_topic?(@topic)
        end
      end

      # Create Topic
      #
      # POST /api/v3/topics
      #
      # @param title [String] Title, [required]
      # @param node_id [Integer] Node ID, [required]
      # @param body [Markdown] format body, [required]
      # @return [TopicDetailSerializer]
      def create
        requires! :title
        requires! :body
        requires! :node_id

        raise AccessDenied.new("The current user does not have permission to create Topic.") unless can?(:create, Topic)

        @topic = current_user.topics.new(title: params[:title], body: params[:body])
        @topic.node_id = params[:node_id]
        @topic.save!

        render "show"
      end

      # Update Topic
      #
      # POST /api/v3/topics/:id
      #
      # @param title [String] Title, [required]
      # @param node_id [Integer] Node ID, [required]
      # @param body [String] Markdown format body, [required]
      # @return [TopicDetailSerializer]
      def update
        requires! :title
        requires! :body
        requires! :node_id

        raise AccessDenied unless can?(:update, @topic)

        if @topic.lock_node == false || can?(:lock_node, @topic)
          # Only admin can change node, when it's has been locked
          @topic.node_id = params[:node_id]

          if @topic.node_id_changed? || can?(:lock_node, @topic)
            # Lock node when admin update
            @topic.lock_node = true
          end
        end
        @topic.title = params[:title]
        @topic.body = params[:body]
        @topic.save!

        render "show"
      end

      # 删除话题
      #
      # DELETE /api/v3/topics/:id
      def destroy
        raise AccessDenied unless can?(:destroy, @topic)
        @topic.destroy_by(current_user)
        render json: {ok: 1}
      end

      # 获取话题的回帖列表
      #
      # GET /api/v3/topics/:id/replies
      #
      # @param offset [Integer] default: 0
      # @param limit [Integer] default: 20, range: 1..150
      # @return [Array<ReplySerializer]>
      def replies
        if request.post?
          create_replies
          return
        end

        params[:limit] ||= 20

        @replies = Reply.unscoped.where(topic_id: @topic.id).order(:id).includes(:user)
        @replies = @replies.offset(params[:offset].to_i).limit(params[:limit].to_i)
        @user_liked_reply_ids = current_user&.like_reply_ids_by_replies(@replies) || []
        @meta = {user_liked_reply_ids: @user_liked_reply_ids}
      end

      # 创建对话题的回帖
      #
      # POST /api/v3/topics/:id/replies
      #
      # @param body [String] 回帖内容，[required]
      # @return [ReplySerializer] 创建的回帖信息
      def create_replies
        doorkeeper_authorize!

        requires! :body

        raise AccessDenied.new("The current user does not have permission to reply to topics.") unless can?(:create, Reply)

        @reply = @topic.replies.build(body: params[:body])
        @reply.user_id = current_user.id
        @reply.save!
        render "api/v3/replies/show"
      end

      # Follow Topic
      #
      # POST /api/v3/topics/:id/follow
      def follow
        current_user.follow_topic(@topic)
        render json: {ok: 1}
      end

      # Unfollow Topic
      #
      # POST /api/v3/topics/:id/unfollow
      def unfollow
        current_user.unfollow_topic(@topic)
        render json: {ok: 1}
      end

      # Favorite Topic
      #
      # POST /api/v3/topics/:id/favorite
      def favorite
        current_user.favorite_topic(@topic.id)
        render json: {ok: 1}
      end

      # Unfovorite Topic
      #
      # POST /api/v3/topics/:id/unfavorite
      def unfavorite
        current_user.unfavorite_topic(@topic.id)
        render json: {ok: 1}
      end

      # Ban Topic (Admin only)
      # [Deprecated] use POST /api/v3/topics/:id/action
      #
      # POST /api/v3/topics/:id/ban
      def ban
        raise AccessDenied.new("The current user does not have the authority to block other people's topics.") unless can?(:ban, @topic)
        @topic.ban!
        render json: {ok: 1}
      end

      # Actions
      # NOTE: The types have different permissions, see GET /api/v3/topics/:id retrurn abilities
      #
      # POST /api/v3/topics/:id/action?type=:type
      # @param type [String] action type, ban - Ban, normal - Unban, excellent - Excellent, unexcellent - Unexcellent, close - Close Topic, open - Reopen Topic
      def action
        raise AccessDenied unless can?(params[:type].to_sym, @topic)

        case params[:type]
        when "excellent"
          @topic.excellent!
        when "unexcellent"
          @topic.unexcellent!
        when "normal"
          @topic.normal!
        when "ban"
          @topic.ban!
        when "close"
          @topic.close!
        when "open"
          @topic.open!
        end
        render json: {ok: 1}
      end

      private

      def set_topic
        @topic = Topic.find(params[:id])
      end

      def scope_method_by_type
        case params[:type]
        when "last_actived" then :last_actived
        when "recent" then :recent
        when "no_reply" then :no_reply
        when "popular" then :popular
        when "excellent" then :excellent
        else
          :last_actived
        end
      end
    end
  end
end
