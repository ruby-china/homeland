class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_likeable

  def index
    @users = @item.liked_users
    render :index, layout: false
  end

  def create
    current_user.like(@item)
    render plain: @item.reload.likes_count
  end

  def destroy
    current_user.unlike(@item)
    render plain: @item.reload.likes_count
  end

  private

  def set_likeable
    @success = false
    @element_id = "likeable_#{params[:type]}_#{params[:id]}"
    unless params[:type].in?(%w(Topic Reply))
      render plain: '-1'
      return false
    end

    case params[:type].downcase
    when 'topic'
      klass = Topic
    when 'reply'
      klass = Reply
    else
      return false
    end

    @item = klass.find_by_id(params[:id])
    render plain: '-2' if @item.blank?
  end
end
