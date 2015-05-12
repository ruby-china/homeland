module V3
  class Topics < Grape::API
    resource :topics do
      desc "Get topics list"
      params do
        optional :type, type: String, default: "last_actived", values: %W(last_actived recent no_reply popular excellent)
        optional :node_id, type: Integer
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
        render @topics.to_a
      end

      desc "Create a Topic"
      params do
        requires :title, type: String
        requires :body, type: String
        requires :node_id, type: Integer
      end
      post '', serializer: TopicDetailSerializer, root: "topic" do
        doorkeeper_authorize!
        @topic = current_user.topics.new(title: params[:title], body: params[:body])
        @topic.node_id = params[:node_id]
        if @topic.save
          render @topic
        else
          error!({ error: @topic.errors.full_messages}, 400)
        end
      end

      namespace ":id" do
        desc "Update Topic"
        params do
          requires :title, type: String
          requires :body, type: String
          requires :node_id, type: Integer
        end
        post "", serializer: TopicDetailSerializer, root: "topic" do
          doorkeeper_authorize!
          #copy from the topicsController#update
          @topic = Topic.find(params[:id])
          error!("没有权限修改", 403) if !owner?(@topic)

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

        desc "Topic detail"
        get "", serializer: TopicDetailSerializer, root: "topic" do
          @topic = Topic.find(params[:id])
          @topic.hits.incr(1)
          render @topic
        end
        
        desc "Topic replies"
        params do
          optional :offset, type: Integer, default: 0
          optional :limit, type: Integer, default: 20, values: 1..150
        end
        get "replies", each_serializer: ReplySerializer, root: "replies" do
          @topic = Topic.find(params[:id])
          @replies = @topic.replies.unscoped.asc(:_id).includes(:user).offset(params[:offset]).limit(params[:limit])
          render @replies
        end
        
        desc "Create a Reply"
        params do
          requires :body, type: String
        end
        post "replies", serializer: ReplySerializer, root: "reply" do
          doorkeeper_authorize!
          @topic = Topic.find(params[:id])
          @reply = @topic.replies.build(body: params[:body])
          @reply.user_id = current_user.id
          if @reply.save
            render @reply
          else
            error!({ error: @reply.errors.full_messages }, 400)
          end
        end
        
        desc "Follow Topic"
        post "follow" do
          doorkeeper_authorize!
          @topic = Topic.find(params[:id])
          @topic.push_follower(current_user.id)
          { ok: 1 }
        end
        
        desc "Unfollow a topic"
        post "unfollow" do
          doorkeeper_authorize!
          @topic = Topic.find(params[:id])
          @topic.pull_follower(current_user.id)
          { ok: 1 }
        end
        
        desc "Favorite Topic"
        post "favorite" do
          doorkeeper_authorize!
          @topic = Topic.find(params[:id])
          current_user.favorite_topic(@topic.id)
          { ok: 1 }
        end
        
        desc "Unfavorite Topic"
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