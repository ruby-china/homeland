# coding: utf-8
class RepliesController < ApplicationController
  before_filter :require_user
  
  def edit
    @reply = current_user.replies.find(params[:id])
    drop_breadcrumb(t("menu.topics"), topics_path)
    drop_breadcrumb t("reply.edit_reply")
  end
  
  def update
    @reply = current_user.replies.find(params[:id])

    if @reply.update_attributes(params[:reply])
      redirect_to(topic_path(@reply.topic_id), :notice => t("reply.delete_reply_success"))
    else
      render :action => "edit"
    end
  end
end