# coding: utf-8  
class ChatsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  # GET /nodes
  # GET /nodes.xml
  def index
    @chats = Chat.desc("_id")
    render :json => @chats, :methods => [:id], :only => [:author,:node_id, :content,:created_at]
  end

  def create
    chat = Chat.new
    chat.id = nil
    chat.content = params[:content]
    chat.node_id = params[:node_id]
    chat.author = current_user.name
    chat.user_id = current_user.id
    chat.save!
    head :ok
  end
  
  def update
    chat = Chat.find(params[:id])
    chat.author = current_user.name
    chat.user_id = current_user.id
    chat.content = params[:content]
    chat.node_id = params[:node_id]
    chat.save
    head :ok
  end
end
