# frozen_string_literal: true

module Admin
  class RepliesController < Admin::ApplicationController
    before_action :set_reply, only: %i[show edit update destroy]

    def index
      @replies = Reply.unscoped
      if params[:q].present?
        qstr = "%#{params[:q].downcase}%"
        @replies = @replies.where("body LIKE ?", qstr)
      end
      if params[:login].present?
        u = User.find_by_login(params[:login])
        @replies = @replies.where("user_id = ?", u.try(:id))
      end
      @replies = @replies.order(id: :desc).includes(:topic, :user)
      @replies = @replies.page(params[:page])
    end

    def show
      redirect_to edit_admin_reply_path(@reply.id)
    end

    def destroy
      if @reply.destroy
        # 积分变动：管理员删除用户评论 如果只剩一条评论被删除时，则扣除积分
        @reply.user.change_score(:delete_comment) if @topic.replies.where(user_id: current_user.id).size == 1
      end
    end

    private

      def set_reply
        @reply = Reply.unscoped.find(params[:id])
      end
  end
end
