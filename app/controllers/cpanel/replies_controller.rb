# coding: utf-8
class Cpanel::RepliesController < Cpanel::ApplicationController

  def index
    @replies = Reply.desc(:_id).paginate :page => params[:page], :per_page => 30
  end

  def show
    @reply = Reply.find(params[:id])

    if @reply.topic.blank?
      redirect_to cpanel_replies_path, :alert => "帖子已经不存在"
    end
  end

  def new
    @reply = Reply.new
  end

  def edit
    @reply = Reply.find(params[:id])
  end


  def create
    @reply = Reply.new(params[:reply])

    if @reply.save
      redirect_to(cpanel_replies_path, :notice => 'Reply was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @reply = Reply.find(params[:id])

    if @reply.update_attributes(params[:reply])
       redirect_to(cpanel_replies_path, :notice => 'Reply was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @reply = Reply.find(params[:id])
    @reply.destroy

    redirect_to(cpanel_replies_path)
  end
end
