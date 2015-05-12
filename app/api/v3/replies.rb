module V3
  class Replies < Grape::API
    resource :replies do
      namespace ":id" do
        before do
          @reply = Reply.find(params[:id])
        end
        
        desc "Get detail of a Reply"
        get "", serializer: ReplyDetailSerializer, root: "reply" do
          render @reply
        end
        
        desc "Update a Reply"
        params do
          requires :body, type: String
        end
        post "" do
          doorkeeper_authorize!
          error!("没有权限修改", 403) if !owner?(@reply)
          @reply.body = params[:body]
          if @reply.save
            { ok: 1 }
          else
            error!({ error: @reply.errors.full_messages }, 400)
          end
        end
        
        desc "Delete a Reply"
        delete "" do
          doorkeeper_authorize!
          error!("没有权限修改", 403) if !owner?(@reply)
          if @reply.destroy
            { ok: 1 }
          else
            error!({ error: "服务器异常，删除失败" }, 500)
          end
        end
      end
    end
  end
end