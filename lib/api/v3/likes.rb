module API
  module V3
    class Likes < Grape::API
      resource :likes do
        params do
          requires :obj_type, type: String, values: %w(topic reply)
          requires :obj_id, type: Integer
        end
        post '' do
          doorkeeper_authorize!
          if params[:obj_type] == 'topic'
            obj = Topic.find(params[:obj_id])
          else
            obj = Reply.find(params[:obj_id])
          end

          current_user.like(obj)
          { obj_type: params[:obj_type], obj_id: obj.id, count: obj.likes_count }
        end

        desc '取消之前的赞'
        params do
          requires :obj_type, type: String, values: %w(topic reply)
          requires :obj_id, type: Integer
        end
        delete '' do
          doorkeeper_authorize!
          if params[:obj_type] == 'topic'
            obj = Topic.find(params[:obj_id])
          else
            obj = Reply.find(params[:obj_id])
          end

          current_user.unlike(obj)
          { obj_type: params[:obj_type], obj_id: obj.id, count: obj.likes_count }
        end
      end
    end
  end

end
