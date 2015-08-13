module V3
  class Replies < Grape::API
    resource :replies do
      namespace ':id' do
        before do
          @reply = Reply.find(params[:id])
        end

        desc '获取回帖的详细内容（一般用于编辑回帖的时候）'
        get '', serializer: ReplyDetailSerializer, root: 'reply' do
          render @reply
        end

        desc '更新回帖'
        params do
          requires :body, type: String
        end
        post '' do
          doorkeeper_authorize!
          error!('没有权限修改', 403) unless can?(:update, @reply)
          @reply.body = params[:body]
          if @reply.save
            { ok: 1 }
          else
            error!({ error: @reply.errors.full_messages }, 400)
          end
        end

        desc '删除回帖'
        delete '' do
          doorkeeper_authorize!
          error!('没有权限修改', 403) unless can?(:destroy, @reply)
          if @reply.destroy
            { ok: 1 }
          else
            error!({ error: '服务器异常，删除失败' }, 500)
          end
        end
      end
    end
  end
end
