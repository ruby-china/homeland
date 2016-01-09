require 'will_paginate/array'
class UsersController < ApplicationController
  before_action :require_user, only: [:block, :unblock, :auth_unbind, :follow, :unfollow]
  before_action :find_user, only: [:show, :topics, :replies, :favorites, :notes,
                                   :block, :unblock, :blocked,
                                   :follow, :unfollow, :followers, :following]

  def index
    @total_user_count = User.count
    @active_users = User.fields_for_list.hot.limit(100)
    set_seo_meta('活跃会员')
  end

  def show
    # 排除掉几个非技术的节点
    without_node_ids = [21, 22, 23, 31, 49, 51, 57, 25]
    @topics = @user.topics.fields_for_list.without_node_ids(without_node_ids).high_likes.limit(20)
    @replies = @user.replies.fields_for_list.recent.includes(:topic).limit(10)
    set_seo_meta("#{@user.login}")
  end

  def topics
    @topics = @user.topics.unscoped.fields_for_list.recent.paginate(page: params[:page], per_page: 40)
    set_seo_meta("#{@user.login} 的帖子")
  end

  def replies
    @replies = @user.replies.fields_for_list.recent.paginate(page: params[:page], per_page: 20)
    set_seo_meta("#{@user.login} 的帖子")
  end

  def favorites
    @topic_ids = @user.favorite_topic_ids.reverse.paginate(page: params[:page], per_page: 40)
    @topics = Topic.where("id IN (?)", @topic_ids).fields_for_list
    @topics = @topics.to_a.sort do |a, b|
      @topic_ids.index(a.id) <=> @topic_ids.index(b.id)
    end
    set_seo_meta("#{@user.login} 的收藏")
  end

  def notes
    @notes = @user.notes.published.recent.paginate(page: params[:page], per_page: 40)
    set_seo_meta("#{@user.login} 的记事本")
  end

  def auth_unbind
    provider = params[:provider]
    if current_user.authorizations.count <= 1
      redirect_to edit_user_registration_path, flash: { error: t('users.unbind_warning') }
      return
    end

    current_user.authorizations.destroy_all(provider: provider)
    redirect_to edit_user_registration_path, flash: { warring: t('users.unbind_success', provider: provider.titleize) }
  end

  def update_private_token
    current_user.update_private_token
    render text: current_user.private_token
  end

  def city
    @location = Location.find_by_name(params[:id])
    if @location.blank?
      render_404
      return
    end

    @users = User.where(location_id: @location.id).fields_for_list.desc('replies_count').paginate(page: params[:page], per_page: 60)

    render_404 if @users.count == 0
  end

  def block
    current_user.block_user(@user.id)
    render json: { code: 0 }
  end

  def unblock
    current_user.unblock_user(@user.id)
    render json: { code: 0 }
  end

  def blocked
    if current_user.id != @user.id
      render_404
    end

    @blocked_users = User.where("id IN (?)", current_user.blocked_user_ids).paginate(page: params[:page], per_page: 20)
  end

  def follow
    current_user.follow_user(@user)
    render json: { code: 0, data: { followers_count: @user.followers_count } }
  end

  def unfollow
    current_user.unfollow_user(@user)
    render json: { code: 0, data: { followers_count: @user.followers_count } }
  end

  def followers
    @users = @user.followers.fields_for_list.paginate(page: params[:page], per_page: 60)
    set_seo_meta("#{@user.login} 的关注者")
  end

  def following
    @users = @user.following.fields_for_list.paginate(page: params[:page], per_page: 60)
    set_seo_meta("#{@user.login} 正在关注")
    render 'followers'
  end

  protected

  def find_user
    # 处理 login 有大写字母的情况
    if params[:id] != params[:id].downcase
      redirect_to request.path.downcase, status: 301
      return
    end

    @user = User.find_login(params[:id])
    if @user.deleted?
      render_404
    end
  end
end
