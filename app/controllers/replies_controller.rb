# frozen_string_literal: true

class RepliesController < ApplicationController
  load_and_authorize_resource :reply

  before_action :set_topic
  before_action :set_reply, only: %i[edit reply_to update destroy]

  def create
    @reply = Reply.new(reply_params)
    @reply.topic_id = @topic.id
    @reply.user_id = current_user.id

    if @reply.save
      current_user.read_topic(@topic)
      @msg = t("replies.created_successfully")
    else
      @msg = @reply.errors.full_messages.join("<br>")
    end
  end

  def index
    last_id = params[:last_id].to_i
    if last_id == 0
      render plain: ""
      return
    end

    @replies = Reply.unscoped.where("topic_id = ? and id > ?", @topic.id, last_id).order(:id).all
    current_user&.read_topic(@topic)
  end

  def show
  end

  def reply_to
    respond_to do |format|
      format.html { render_404 }
      format.js
    end
  end

  def edit
  end

  def update
    @reply.update(reply_params)
  end

  def destroy
    if @reply.destroy
      redirect_to(topic_path(@reply.topic_id), notice: t("replies.deleted_successfully"))
    else
      redirect_to(topic_path(@reply.topic_id), alert: t("common.unknow_error"))
    end
  end

  protected

  def set_topic
    @topic = Topic.find(params[:topic_id])
  end

  def set_reply
    @reply = Reply.find(params[:id])
  end

  def reply_params
    params.require(:reply).permit(:body, :reply_to_id)
  end
end
