# coding: utf-8
require 'will_paginate/array'
class UsersController < ApplicationController
  before_action :require_user, only: [:block, :unblock, :auth_unbind, :follow, :unfollow]
  before_filter :find_user, only: [:show, :topics, :favorites, :notes, 
                                   :block, :unblock, :blocked,
                                   :follow, :unfollow, :followers, :following]
  caches_action :index, expires_in: 2.hours, layout: false

  def index
    @total_user_count = User.count
    @active_users = User.hot.limit(100)
  end

  def show
    # 排除掉几个非技术的节点
    without_node_ids = [21, 22, 23, 31, 49, 51, 57, 25]
    @topics = @user.topics.without_node_ids(without_node_ids).high_likes.limit(20)
    @replies = @user.replies.only(:topic_id, :body_html, :created_at).recent.includes(:topic).limit(10)
    set_seo_meta("#{@user.login}")
  end

  def topics
    @topics = @user.topics.recent.paginate(page: params[:page], per_page: 30)
  end

  def favorites
    @topic_ids = @user.favorite_topic_ids.reverse.paginate(page: params[:page], per_page: 30)
    @topics = Topic.where(:_id.in => @topic_ids)
    @topics = @topics.to_a.sort do |a, b|
      @topic_ids.index(a.id) <=> @topic_ids.index(b.id)
    end
  end

  def notes
    @notes = @user.notes.published.recent.paginate(page: params[:page], per_page: 30)
  end

  def auth_unbind
    provider = params[:provider]
    if current_user.authorizations.count <= 1
      redirect_to edit_user_registration_path, flash: { error: t("users.unbind_warning") }
      return
    end

    current_user.authorizations.destroy_all({ provider: provider })
    redirect_to edit_user_registration_path, flash: { warring: t("users.unbind_success", provider: provider.titleize) }
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

    @users = User.where(location_id: @location.id).desc('replies_count').paginate(page: params[:page], per_page: 60)

    if @users.count == 0
      render_404
      return
    end
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

    @blocked_users = User.where(:_id.in => current_user.blocked_user_ids).paginate(page: params[:page], per_page: 20)
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
    @users = @user.followers.paginate(page: params[:page], per_page: 60)
  end
  
  def following
    @users = @user.following.paginate(page: params[:page], per_page: 60)
    render "followers"
  end

  protected
  def find_user
    # 处理 login 有大写字母的情况
    if params[:id] != params[:id].downcase
      redirect_to request.path.downcase, status: 301
      return
    end

    @user = User.find_login(params[:id])
  end

end
