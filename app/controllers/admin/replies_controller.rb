module Admin
  class RepliesController < ApplicationController
    def index
      @replies = Reply.unscoped.order(id: :desc).includes(:topic, :user).paginate page: params[:page], per_page: 30
    end

    def show
      @reply = Reply.unscoped.find(params[:id])

      if @reply.topic.blank?
        redirect_to admin_replies_path, alert: '帖子已经不存在'
      end
    end

    def new
      @reply = Reply.new
    end

    def edit
      @reply = Reply.unscoped.find(params[:id])
    end

    def create
      @reply = Reply.new(params[:reply].permit!)

      if @reply.save
        redirect_to(admin_replies_path, notice: 'Reply was successfully created.')
      else
        render action: 'new'
      end
    end

    def update
      @reply = Reply.unscoped.find(params[:id])

      if @reply.update_attributes(params[:reply].permit!)
        redirect_to(admin_replies_path, notice: 'Reply was successfully updated.')
      else
        render action: 'edit'
      end
    end

    def destroy
      @reply = Reply.unscoped.find(params[:id])
      @reply.destroy
    end
  end
end
