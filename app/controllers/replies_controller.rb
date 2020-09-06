# frozen_string_literal: true

class RepliesController < ApplicationController
  load_and_authorize_resource :reply

  before_action :set_topic
  before_action :set_reply, only: %i[edit reply_to update destroy]

  def create
    @reply = Reply.new(reply_params)
    @reply.topic_id = @topic.id
    @reply.user_id = current_user.id

    # 加入匿名
    if @topic.belongs_to_nickname_node? && @reply.anonymous == 0
      @reply.user_id = User.anonymous_user_id
      @reply.real_user_id = current_user.id
    end

    if @reply.save
      current_user.read_topic(@topic)
      @msg = t("topics.reply_success")
    else
      @msg = @reply.errors.full_messages.join("<br />")
    end
  end

  def index
    last_id = params[:last_id].to_i
    if last_id == 0
      render plain: ""
      return
    end

    @replies = Reply.unscoped.where("topic_id = ? and id > ?", @topic.id, last_id).order(:id).all
    current_user&.read_topic(@topic, replies_ids: @replies.collect(&:id))
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
      redirect_to(topic_path(@reply.topic_id), notice: "回帖删除成功。")
    else
      redirect_to(topic_path(@reply.topic_id), alert: "程序异常，删除失败。")
    end
  end

  def reply_suggest
    @reply.update_suggested_at(Time.now)
    redirect_to(topic_path(@reply.topic_id), notice: "设为最佳回复成功。")
  end

  def reply_unsuggest
    @reply.update_suggested_at(nil)
    redirect_to(topic_path(@reply.topic_id), notice: "取消最佳回复成功。")
  end

  protected

    def set_topic
      # 兼容 topic 和 article
      if (params[:topic_id])
        @topic = Topic.find(params[:topic_id])
      else
        @topic = Topic.find(params[:article_id])
      end
    end

    def set_reply
      @reply = Reply.find(params[:id])
    end

    def reply_params
      params.require(:reply).permit(:body, :reply_to_id, :anonymous, :exposed_to_author_only)
    end
end
