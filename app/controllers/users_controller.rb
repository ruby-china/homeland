require 'will_paginate/array'

class UsersController < ApplicationController
  before_action :set_user, except: [:index, :city]

  etag { @user }
  etag { @user&.teams }

  include Users::TeamActions
  include Users::UserActions

  def index
    @total_user_count = User.count
    @active_users = User.fields_for_list.hot.limit(100)
    fresh_when([@total_user_count, @active_users])
  end

  def city
    @location = Location.location_find_by_name(params[:id])
    if @location.blank?
      render_404
      return
    end

    @users = User.where(location_id: @location.id).fields_for_list
    @users = @users.order(replies_count: :desc).paginate(page: params[:page], per_page: 60)

    render_404 if @users.count == 0
  end

  def show
    @user_type == :team ? team_show : user_show
  end

  protected

  def set_user
    # 处理 login 有大写字母的情况
    if params[:id] != params[:id].downcase
      redirect_to request.path.downcase, status: 301
      return
    end

    @user = User.find_login!(params[:id])
    @user_type = @user.user_type
    if @user.deleted?
      render_404
    end
  end

  # Override render method to render difference view path
  def render(*args)
    options = args.extract_options!
    if @user_type
      options[:template] ||= "/#{@user_type.to_s.tableize}/#{params[:action]}"
    end
    super(*(args << options))
  end
end
