module API
  module V3
    class Users < Grape::API
      resource :users do
        # Get top 20 hot users
        params do
          optional :limit, type: Integer, default: 20, values: 1..150
        end
        get do
          params[:limit] = 100 if params[:limit] > 100
          @users = User.fields_for_list.hot.limit(params[:limit])
          render @users
        end

        desc '获取当然登陆者的资料'
        get 'me', serializer: UserDetailSerializer, root: 'user' do
          doorkeeper_authorize!
          render current_user
        end

        namespace ':login' do
          before do
            @user = User.find_login!(params[:login])
          end

          desc '获取用户详细资料'
          get '', serializer: UserDetailSerializer, root: 'user' do
            meta = { followed: false, blocked: false }

            if current_user
              meta[:followed] = current_user.followed?(@user)
              meta[:blocked] = current_user.blocked_user?(@user)
            end

            render @user, meta: meta
          end

          desc '获取用户创建的话题列表'
          params do
            optional :order, type: String, default: 'recent', values: %w(recent likes replies)
            optional :offset, type: Integer, default: 0
            optional :limit, type: Integer, default: 20, values: 1..150
          end
          get 'topics', each_serializer: TopicSerializer, root: 'topics' do
            @topics = @user.topics.fields_for_list
            if params[:order] == 'likes'
              @topics = @topics.high_likes
            elsif params[:order] == 'replies'
              @topics = @topics.high_replies
            else
              @topics = @topics.recent
            end
            @topics = @topics.includes(:user).offset(params[:offset]).limit(params[:limit])
            render @topics
          end

          desc '获取用户创建的回帖列表'
          params do
            optional :order, type: String, default: 'recent', values: %w(recent)
            optional :offset, type: Integer, default: 0
            optional :limit, type: Integer, default: 20, values: 1..150
          end
          get 'replies', each_serializer: ReplyDetailSerializer, root: 'replies' do
            @replies = @user.replies.recent
            @replies = @replies.includes(:user, :topic).offset(params[:offset]).limit(params[:limit])
            render @replies
          end

          desc '用户收藏的话题列表'
          params do
            optional :offset, type: Integer, default: 0
            optional :limit, type: Integer, default: 20, values: 1..150
          end
          get 'favorites', each_serializer: TopicSerializer, root: 'topics' do
            @topic_ids = @user.favorite_topic_ids[params[:offset].to_i, params[:limit].to_i]
            @topics = Topic.where(id: @topic_ids).fields_for_list.includes(:user)
            @topics = @topics.to_a.sort do |a, b|
              @topic_ids.index(a.id) <=> @topic_ids.index(b.id)
            end
            render @topics
          end

          desc '用户的关注者列表'
          params do
            optional :offset, type: Integer, default: 0
            optional :limit, type: Integer, default: 20, values: 1..150
          end
          get 'followers', each_serializer: UserSerializer, root: 'followers' do
            @users = @user.followers.fields_for_list.offset(params[:offset]).limit(params[:limit])
            render @users
          end

          desc '用户正在关注的人'
          params do
            optional :offset, type: Integer, default: 0
            optional :limit, type: Integer, default: 20, values: 1..150
          end
          get 'following', each_serializer: UserSerializer, root: 'following' do
            @users = @user.following.fields_for_list.offset(params[:offset]).limit(params[:limit])
            render @users
          end

          desc '用户屏蔽的用户'
          params do
            optional :offset, type: Integer, default: 0
            optional :limit, type: Integer, default: 20, values: 1..150
          end
          get 'blocked', each_serializer: UserSerializer, root: 'blocked' do
            doorkeeper_authorize!
            error!({ error: '不可以获取其他人的 blocked_users 列表。' }, 403) if current_user.id != @user.id

            user_ids = current_user.blocked_user_ids[params[:offset], params[:limit]]
            @blocked_users = User.where(id: user_ids)
            render @blocked_users
          end

          desc '关注用户'
          post 'follow' do
            doorkeeper_authorize!
            current_user.follow_user(@user)
            { ok: 1 }
          end

          desc '取消关注用户'
          post 'unfollow' do
            doorkeeper_authorize!
            current_user.unfollow_user(@user)
            { ok: 1 }
          end

          desc '屏蔽用户'
          post 'block' do
            doorkeeper_authorize!
            current_user.block_user(@user.id)
            { ok: 1 }
          end

          desc '取消屏蔽用户'
          post 'unblock' do
            doorkeeper_authorize!
            current_user.unblock_user(@user.id)
            { ok: 1 }
          end
        end
      end
    end
  end
end
