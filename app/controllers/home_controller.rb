# coding: utf-8  
class HomeController < ApplicationController
  before_filter :require_no_user, :only => [:login, :login_create]
  before_filter :require_user, :only => :logout
  
  
  def index
    if !fragment_exist? "home/last_topics"
      @last_topics = Topic.recents.limit(10)
    end
    if !fragment_exist? "home/actived_topics"
      @actived_topics = Topic.last_actived.limit(10)
    end
  end
  
  def login
    @user_session = UserSession.new
  end
  
  def login_create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_back_or_default root_path
    else
      render :action => :login
    end
  end
  
  def logout
    current_user_session.destroy
    redirect_back_or_default root_path
  end

	def auth_callback
		auth = request.env["omniauth.auth"]  
		@auth = Authorization.find_from_hash(auth)
		if current_user
      flash[:notice] = "Successfully added #{auth['provider']} authentication"
      current_user.authorizations.create(:provider => auth['provider'], :uid => auth['uid']) #Add an auth to existing
		elsif @auth
			flash[:notice] = "Welcome back #{auth['provider']} user"
      UserSession.create(@auth.user, true) #User is present. Login the user with his social account
		else
			@new_auth = Authorization.create_from_hash(auth, current_user) #Create a new user
      flash[:notice] = "Welcome #{auth['provider']} user. Your account has been created."
      UserSession.create(@new_auth.user, true) #Log the authorizing user in.
		end
		redirect_to root_url
	end
end
