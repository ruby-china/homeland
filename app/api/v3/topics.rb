module V3
  class Topics < Grape::API
    resource :topics do
      desc %(获取话题列表

### Returns:

```json
{
    "topics": [
        {
            "id": 25262,
            "title": "Rails 中自动布署工具 mina 的经验谈",
            "created_at": "2015-05-12T22:08:53.509+08:00",
            "updated_at": "2015-05-12T22:09:10.772+08:00",
            "replied_at": "2015-05-12T22:09:10.005+08:00",
            "replies_count": 1,
            "node_name": "Sinatra",
            "node_id": 43,
            "last_reply_user_id": 2,
            "last_reply_user_login": "huacnlee",
            "user": {
                "id": 35,
                "login": "monster",
                "name": null,
                "avatar_url": "http://gravatar.com/avatar/dba7c3f68c94ec5f7ac96d0a5e7db205.png?s=120"
            },
            "deleted": false,
            "abilities": {
                "update": true,
                "destroy": true
            }
        },
        {
            "id": 25253,
            "title": "旧爱 Bootstrap，新欢 Materialize",
            "created_at": "2015-04-22T18:12:53.160+08:00",
            "updated_at": "2015-05-18T20:50:44.486+08:00",
            "replied_at": "2015-05-12T21:59:13.520+08:00",
            "replies_count": 10,
            "node_name": "分享",
            "node_id": 26,
            "last_reply_user_id": 2,
            "last_reply_user_login": "huacnlee",
            "user": { ... },
            "deleted": false,
            "abilities": {
                "update": true,
                "destroy": true
            }
        },
        ...
    ]
}
```
)
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
        if %W(no_reply popular).index(params[:type])
          @topics = @topics.last_actived
        elsif params[:type] == "excellent"
          @topics = @topics.recent
        end

        @topics = @topics.offset(params[:offset]).limit(params[:limit])
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

        desc %(获取完整的话题内容

### Returns:

```json
{
    "topic": {
        "id": 25209,
        "title": "Rails 4.2 中 ActiveJob 的使用",
        "created_at": "2015-04-20T13:01:24.262+08:00",
        "updated_at": "2015-04-23T20:00:09.008+08:00",
        "replied_at": "2015-04-23T19:47:28.173+08:00",
        "replies_count": 10,
        "node_name": "Rails",
        "node_id": 2,
        "last_reply_user_id": 2,
        "last_reply_user_login": "huacnlee",
        "user": {
            "id": 10547,
            "login": "jicheng1014",
            "name": "哥有石头",
            "avatar_url": "http://gravatar.com/avatar/ac312b6f8e75f1e2db5026b7a67078ba.png?s=120"
        },
        "deleted": false,
        "abilities": {
            "update": false,
            "destroy": false
        },
        "body": "## 初探ActiveJob",
        "body_html": "<h4>初探ActiveJob</h4>",
        "hits": 19
    }
}
```
)
        get "", serializer: TopicDetailSerializer, root: "topic" do
          @topic = Topic.find(params[:id])
          @topic.hits.incr(1)
          render @topic
        end

        desc %(获取某个话题的回帖列表

### Returns:

```json
{
    "replies": [
        {
            "id": 248607,
            "body_html": "<p>在我刚毕业的时候读过这一篇, 收获颇丰.</p>",
            "created_at": "2015-02-23T14:14:52.043+08:00",
            "updated_at": "2015-02-23T14:14:52.043+08:00",
            "deleted": false,
            "topic_id": 24325,
            "user": {
                "id": 121,
                "login": "lyfi2003",
                "name": "windy",
                "avatar_url": "http://ruby-china-files-dev.b0.upaiyun.com/user/large_avatar/121.jpg"
            },
            "abilities": {
                "update": false,
                "destroy": false
            }
        },
        {
            "id": 248608,
            "body_html": "<p>投精华和置顶！</p>",
            "created_at": "2015-02-23T14:41:32.977+08:00",
            "updated_at": "2015-02-23T14:41:32.977+08:00",
            "deleted": false,
            "topic_id": 24325,
            "user": { ... },
            "abilities": {
                "update": false,
                "destroy": false
            }
        },
        ...
    ]
}
```
)
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