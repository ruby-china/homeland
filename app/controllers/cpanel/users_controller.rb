# coding: utf-8  
class Cpanel::UsersController < Cpanel::ApplicationController
  # GET /users
  # GET /users.xml
  def index
    @users = User.desc(:_id).paginate :page => params[:page], :per_page => 30

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
    @user._id = nil

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])    
    @user.email = params[:user][:email]
    @user.login = params[:user][:login]
    @user.state = params[:user][:state]
    @user.verified = params[:user][:verified]

    respond_to do |format|
      if @user.save
        format.html { redirect_to(cpanel_users_path, :notice => 'User was successfully created.') }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    @user.email = params[:user][:email]
    @user.name = params[:user][:name]
    @user.login = params[:user][:login]
    @user.state = params[:user][:state]
    @user.verified = params[:user][:verified]
    
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(cpanel_users_path, :notice => 'User was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(cpanel_users_url) }
      format.xml  { head :ok }
    end
  end
end
