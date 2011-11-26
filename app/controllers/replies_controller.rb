# coding: utf-8
class RepliesController < ApplicationController
  before_filter :require_user
  
  def edit
    @reply = current_user.replies.find(params[:id])
    drop_breadcrumb("社区", topics_path)
    drop_breadcrumb("修改回帖")
  end
  
  def update
    @reply = current_user.replies.find(params[:id])

    if @reply.update_attributes(params[:reply])
      redirect_to(topic_path(@reply.topic_id), :notice => '回帖更新成功.')
    else
      render :action => "edit"
    end
  end
end