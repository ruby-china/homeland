# coding: utf-8
class Cpanel::UsersController < Cpanel::ApplicationController

  def index
    @users = User.desc(:_id).paginate :page => params[:page], :per_page => 30

  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
    @user._id = nil
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user].permit!)
    @user.email = params[:user][:email]
    @user.login = params[:user][:login]
    @user.state = params[:user][:state]
    @user.verified = params[:user][:verified]

    if @user.save
      redirect_to(cpanel_users_path, :notice => 'User was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @user = User.find(params[:id])
    @user.email = params[:user][:email]
    @user.login = params[:user][:login]
    @user.state = params[:user][:state]
    @user.verified = params[:user][:verified]

    if @user.update_attributes(params[:user].permit!)
      redirect_to(edit_cpanel_user_path(@user.id), :notice => 'User was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.soft_delete

    redirect_to(cpanel_users_url)
  end
end
