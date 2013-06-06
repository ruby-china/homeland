# coding: utf-8
class RepliesController < ApplicationController

  load_and_authorize_resource :reply

  before_filter :find_topic
  def create

    @reply = Reply.new(reply_params)
    @reply.topic_id = @topic.id
    @reply.user_id = current_user.id

    if @reply.save
      current_user.read_topic(@topic)
      @msg = t("topics.reply_success")
    else
      @msg = @reply.errors.full_messages.join("<br />")
    end
  end

  def edit
    @reply = Reply.find(params[:id])
    drop_breadcrumb(t("menu.topics"), topics_path)
    drop_breadcrumb t("reply.edit_reply")
  end

  def update
    @reply = Reply.find(params[:id])

    if @reply.update_attributes(reply_params)
      redirect_to(topic_path(@reply.topic_id), :notice => '回帖更新成功.')
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @reply = Reply.find(params[:id])
    if @reply.destroy
      redirect_to(topic_path(@reply.topic_id), :notice => '回帖删除成功.')
    else
      redirect_to(topic_path(@reply.topic_id), :alert => '程序异常，删除失败.')
    end
  end

  protected

  def find_topic
    @topic = Topic.find(params[:topic_id])
  end
  
  def reply_params
    params.require(:reply).permit(:body)
  end

end
