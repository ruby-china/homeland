class RepliesController < ApplicationController
  load_and_authorize_resource :reply

  before_action :set_topic
  before_action :set_reply, only: [:edit, :update, :destroy]

  def create
    @reply = Reply.new(reply_params)
    @reply.topic_id = @topic.id
    @reply.user_id = current_user.id

    if @reply.save
      @replies_count = @topic.replies_count + 1
      current_user.read_topic(@topic)
      @msg = t('topics.reply_success')
    else
      @msg = @reply.errors.full_messages.join('<br />')
    end
  end

  def index
    last_id = params[:last_id].to_i
    if last_id == 0
      render plain: ''
      return
    end

    @replies = Reply.unscoped.where('topic_id = ? and id > ?', @topic.id, last_id).without_body.order(:id).all
    if current_user
      current_user.read_topic(@topic, replies_ids: @replies.collect(&:id))
    end
  end

  def show
  end

  def edit
  end

  def update
    @reply.update_attributes(reply_params)
  end

  def destroy
    if @reply.destroy
      redirect_to(topic_path(@reply.topic_id), notice: '回帖删除成功。')
    else
      redirect_to(topic_path(@reply.topic_id), alert: '程序异常，删除失败。')
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
    params.require(:reply).permit(:body)
  end
end
