module V3
  class Topics < Grape::API
    resource :topics do
      desc "获取话题列表"
      params do
        optional :type, type: String, default: "last_actived", 
                 values: %W(last_actived recent no_reply popular excellent),
                 desc: %(- last_actived - 最近更新的（社区默认排序）
- recent - 最新创建（会包含 NoPoint 的）
- no_reply - 还没有任何回帖的
- popular - 热门的话题（回帖和喜欢超过一定的数量）
- excellent - 精华帖
)
        optional :node_id, type: Integer, desc: "如果你需要只看某个节点的，请传此参数"
        optional :offset, type: Integer, default: 0
        optional :limit, type: Integer, default: 20, values: 1..150
      end
      get '', each_serializer: TopicSerializer, root: "topics" do
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

        @topics = @topics.fields_for_list.includes(:user)
                         .send(params[:type])
                         .offset(params[:offset]).limit(params[:limit])
        render @topics
      end

      desc "创建话题"
      params do
        requires :title, type: String, desc: "话题标题"
        requires :body, type: String, desc: "话题内容, Markdown 格式"
        requires :node_id, type: Integer, desc: "节点编号"
      end
      post '', serializer: TopicDetailSerializer, root: "topic" do
        doorkeeper_authorize!
        error!("当前登录的用户没有发帖权限，具体请参考官网的相关说明。", 403) if !can?(:create, Topic)
        @topic = current_user.topics.new(title: params[:title], body: params[:body])
        @topic.node_id = params[:node_id]
        if @topic.save
          render @topic
        else
          error!({ error: @topic.errors.full_messages}, 400)
        end
      end

      namespace ":id" do
        desc "更新话题"
        params do
          requires :title, type: String, desc: "话题标题"
          requires :body, type: String, desc: "话题内容, Markdown 格式"
          requires :node_id, type: Integer, desc: "节点编号"
        end
        post "", serializer: TopicDetailSerializer, root: "topic" do
          doorkeeper_authorize!
          #copy from the topicsController#update
          @topic = Topic.find(params[:id])
          error!("没有权限修改话题", 403) if !can?(:update, @topic)

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
          if @topic.save
            render @topic
          else
            error!({ error: @topic.errors.full_messages }, 400)
          end
        end

        desc "获取完整的话题内容"
        get "", serializer: TopicDetailSerializer, root: "topic" do
          @topic = Topic.find(params[:id])
          @topic.hits.incr(1)
          render @topic
        end
        
        desc "获取某个话题的回帖列表"
        params do
          optional :offset, type: Integer, default: 0
          optional :limit, type: Integer, default: 20, values: 1..150
        end
        get "replies", each_serializer: ReplySerializer, root: "replies" do
          @topic = Topic.find(params[:id])
          @replies = @topic.replies.unscoped.asc(:_id).includes(:user).offset(params[:offset]).limit(params[:limit])
          render @replies
        end
        
        desc "创建回帖"
        params do
          requires :body, type: String, desc: "回帖内容, Markdown 格式"
        end
        post "replies", serializer: ReplySerializer, root: "reply" do
          doorkeeper_authorize!
          error!("当前用户没有回帖权限，具体请参考官网的说明。", 403) if !can?(:create, Reply)
          @topic = Topic.find(params[:id])
          @reply = @topic.replies.build(body: params[:body])
          @reply.user_id = current_user.id
          if @reply.save
            render @reply
          else
            error!({ error: @reply.errors.full_messages }, 400)
          end
        end
        
        desc "关注话题"
        post "follow" do
          doorkeeper_authorize!
          @topic = Topic.find(params[:id])
          @topic.push_follower(current_user.id)
          { ok: 1 }
        end
        
        desc "取消关注话题"
        post "unfollow" do
          doorkeeper_authorize!
          @topic = Topic.find(params[:id])
          @topic.pull_follower(current_user.id)
          { ok: 1 }
        end
        
        desc "收藏话题"
        post "favorite" do
          doorkeeper_authorize!
          @topic = Topic.find(params[:id])
          current_user.favorite_topic(@topic.id)
          { ok: 1 }
        end
        
        desc "取消收藏话题"
        post "unfavorite" do
          doorkeeper_authorize!
          @topic = Topic.find(params[:id])
          current_user.unfavorite_topic(@topic.id)
          { ok: 1 }
        end
      end
      
    end

  end
end