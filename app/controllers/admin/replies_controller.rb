module Admin
  class RepliesController < Admin::ApplicationController
    before_action :set_reply, only: [:show, :edit, :update, :destroy]

    def index
      @replies = Reply.unscoped.order(id: :desc).includes(:topic, :user)
      @replies = @replies.paginate(page: params[:page], per_page: 30)
    end

    def show
      if @reply.topic.blank?
        redirect_to admin_replies_path, alert: '帖子已经不存在'
      end
    end

    def destroy
      @reply.destroy
    end

    private

    def set_reply
      @reply = Reply.unscoped.find(params[:id])
    end
  end
end
