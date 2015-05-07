module V3
  class Topics < Grape::API
    resource :topics do
      # Get active topics list
      # params[:page]
      # params[:per_page]: default is 30
      # params[:type]: default(or empty) excellent no_reply popular last
      # Example
      #   /api/v3/topics/index.json?page=1&per_page=15
      get do
        @topics = Topic.last_actived.without_hide_nodes
        @topics = @topics.send(params[:type]) if ['excellent', 'no_reply', 'popular', 'recent'].include?(params[:type])
        @topics = @topics.includes(:user).paginate(page: params[:page], per_page: params[:per_page] || 30)
        present @topics, with: V3::Entities::Topic
      end

      # Get active topics of the specified node
      # params[:id]: node id
      # params[:page]
      # params[:size] or params[:per_page]: default is 15, maximum is 100
      # params[:type]: default(or empty) excellent no_reply popular last
      # other params are same to those of topics#index
      # Example
      #   /api/v3/topics/node/1.json?size=30
      get "node/:id" do
        @node = Node.find(params[:id])
        @topics = @node.topics.last_actived
        @topics = @topics.send(params[:type]) if ['excellent', 'no_reply', 'popular', 'recent'].include?(params[:type])
        @topics = @topics.includes(:user).paginate(page: params[:page], per_page: params[:per_page] || page_size)
        present @topics, with: V3::Entities::Topic
      end

      # Post a new topic
      # require authentication
      # params:
      #   title
      #   body
      #   node_id
      post do
        doorkeeper_authorize!
        @topic = current_user.topics.new(title: params[:title], body: params[:body])
        @topic.node_id = params[:node_id]
        if @topic.save
          present @topic, with: V3::Entities::DetailTopic
        else
          error!({ error: @topic.errors.full_messages }, 400)
        end
      end

      # Edit a topic
      # require authentication
      # params:
      #   title
      #   body
      post ":id" do
        doorkeeper_authorize!
        #copy from the topicsController#update
        @topic = Topic.find(params[:id])
        if @topic.lock_node == false || current_user.admin?
          # 锁定接点的时候，只有管理员可以修改节点
          @topic.node_id = params[:node_id]

          if current_user.admin? && @topic.node_id_changed?
            # 当管理员修改节点的时候，锁定节点
            @topic.lock_node = true
          end
        end
        @topic.title = params[:title]
        @topic.body = params[:body]
        @topic.save

        present @topic, with: V3::Entities::DetailTopic, include_deleted: params[:include_deleted]
      end
    
      # Get topic detail
      # params:
      #   include_deleted(optional)
      # Example
      #   /api/v3/topics/1.json
      get ":id" do
        @topic = Topic.find(params[:id])
        @topic.hits.incr(1)
        present @topic, with: V3::Entities::DetailTopic, include_deleted: params[:include_deleted]
      end

      # Post a new reply
      # require authentication
      # params:
      #   body
      # Example
      #   /api/v3/topics/1/replies.json
      post ":id/replies" do
        doorkeeper_authorize!
        @topic = Topic.find(params[:id])
        @reply = @topic.replies.build(body: params[:body])
        @reply.user_id = current_user.id
        if @reply.save
          present @reply, with: V3::Entities::Reply
        else
          error!({"error" => @reply.errors.full_messages }, 400)
        end
      end

      # Follow a topic
      # require authentication
      # params:
      #   NO
      # Example
      #   /api/v3/topics/1/follow.json
      post ":id/follow" do
        doorkeeper_authorize!
        @topic = Topic.find(params[:id])
        @topic.push_follower(current_user.id)
      end

      # Unfollow a topic
      # require authentication
      # params:
      #   NO
      # Example
      #   /api/v3/topics/1/unfollow.json
      post ":id/unfollow" do
        doorkeeper_authorize!
        @topic = Topic.find(params[:id])
        @topic.pull_follower(current_user.id)
      end

      # Add/Remove a topic to/from favorite
      # require authentication
      # params:
      #   type(optional) default is empty, set it unfavoritate to remove favorite
      # Example
      #   /api/v3/topics/1/favorite.json
      post ":id/favorite" do
        doorkeeper_authorize!
        if params[:type] == "unfavorite"
          current_user.unfavorite_topic(params[:id])
        else
          current_user.favorite_topic(params[:id])
        end
      end
    end
    
  end
end