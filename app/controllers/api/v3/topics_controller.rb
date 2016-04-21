module Api
  module V3
    class TopicsController < ApplicationController
      before_action :doorkeeper_authorize!, except: [:index, :show, :replies]
      before_action :set_topic, except: [:index, :create]

      def index
        optional! :type, default: 'last_actived',
                         values: %w(last_actived recent no_reply popular excellent)
        optional! :node_id
        optional! :offset, default: 0
        optional! :limit, default: 20, values: 1..150

        params[:type].downcase!

        if params[:node_id].blank?
          @topics = Topic
          if current_user
            @topics = @topics.without_nodes(current_user.blocked_node_ids)
            @topics = @topics.without_users(current_user.blocked_user_ids)
          else
            @topics = @topics.without_hide_nodes
          end
        else
          @node = Node.find(params[:node_id])
          @topics = @node.topics
        end

        @topics = @topics.fields_for_list.includes(:user).send(params[:type])
        if %w(no_reply popular).index(params[:type])
          @topics = @topics.last_actived
        elsif params[:type] == 'excellent'
          @topics = @topics.recent
        end

        @topics = @topics.offset(params[:offset]).limit(params[:limit])
        render json: @topics
      end

      def show
        @topic.hits.incr(1)
        meta = { followed: false, liked: false, favorited: false }

        if current_user
          # 处理通知
          current_user.read_topic(@topic)
          meta[:followed] = @topic.followed?(current_user.id)
          meta[:liked] = current_user.liked?(@topic)
          meta[:favorited] = current_user.favorited_topic?(@topic.id)
        end

        render json: @topic, serializer: TopicDetailSerializer, meta: meta
      end

      # 创建话题
      def create
        requires! :title
        requires! :body
        requires! :node_id

        raise AccessDenied.new('当前登录的用户没有发帖权限，具体请参考官网的相关说明。') unless can?(:create, Topic)

        @topic = current_user.topics.new(title: params[:title], body: params[:body])
        @topic.node_id = params[:node_id]
        @topic.save!


        render json: @topic, serializer: TopicDetailSerializer, status: 201
      end

      # 更新话题
      def update
        requires! :title
        requires! :body
        requires! :node_id

        raise AccessDenied unless can?(:update, @topic)

        if @topic.lock_node == false || admin?
          # 锁定接点的时候，只有管理员可以修改节点
          @topic.node_id = params[:node_id]

          if admin? && @topic.node_id_changed?
            # 当管理员修改节点的时候，锁定节点
            @topic.lock_node = true
          end
        end
        @topic.title = params[:title]
        @topic.body = params[:body]
        @topic.save!

        render json: @topic, serializer: TopicDetailSerializer, status: 201
      end

      def destroy
        raise AccessDenied unless can?(:destroy, @topic)
        @topic.destroy_by(current_user)
        render json: { ok: 1 }
      end

      # 获取帖子的回帖
      def replies
        if request.post?
          create_replies
          return
        end

        @replies = Reply.unscoped.where(topic_id: @topic.id).order(:id).includes(:user)
        @replies = @replies.offset(params[:offset]).limit(params[:limit])

        @user_liked_reply_ids = []
        if current_user
          # 找出用户 like 过的 Reply，给 JS 处理 like 功能的状态
          @replies.each do |r|
            unless r.liked_user_ids.index(current_user.id).nil?
              @user_liked_reply_ids << r.id
            end
          end
        end

        render json: @replies, meta: { user_liked_reply_ids: @user_liked_reply_ids }
      end

      # 创建回帖
      def create_replies
        doorkeeper_authorize!

        requires! :body

        raise AccessDenied.new('当前用户没有回帖权限，具体请参考官网的说明。') unless can?(:create, Reply)

        @reply = @topic.replies.build(body: params[:body])
        @reply.user_id = current_user.id
        @reply.save!
        render json: @reply, status: 201
      end

      def follow
        @topic.push_follower(current_user.id)
        render json: { ok: 1 }, status: 201
      end

      def unfollow
        @topic.pull_follower(current_user.id)
        render json: { ok: 1 }, status: 201
      end

      def favorite
        current_user.favorite_topic(@topic.id)
        render json: { ok: 1 }, status: 201
      end

      def unfavorite
        current_user.unfavorite_topic(@topic.id)
        render json: { ok: 1 }, status: 201
      end

      # 屏蔽话题，移到 NoPoint 节点 (Admin only)
      def ban
        raise AccessDenied.new('当前用户没有屏蔽别人话题的权限，具体请参考官网的说明。') unless can?(:ban, @topic)
        @topic.ban!
        render json: { ok: 1 }, status: 201
      end

      private
      def set_topic
        @topic = Topic.find(params[:id])
      end
    end
  end
end
