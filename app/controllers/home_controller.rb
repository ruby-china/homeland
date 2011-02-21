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

	def auth_callback
		auth = request.env["omniauth.auth"]  
		redirect_to root_path if auth.blank?

		@auth = Authorization.find_from_hash(auth)
		if current_user
      current_user.authorizations.create(:provider => auth['provider'], :uid => auth['uid']) #Add an auth to existing
      flash[:notice] = "成功绑定了 #{auth['provider']} 帐号。"
			redirect_to setting_path
		elsif @auth
      UserSession.create(@auth.user, true) #User is present. Login the user with his social account
			flash[:notice] = "登陆成功。"
			redirect_to root_url
		else
			@new_auth = Authorization.create_from_hash(auth, current_user) #Create a new user
      UserSession.create(@new_auth.user, true) #Log the authorizing user in.
      flash[:notice] = "欢迎来自 #{auth['provider']} 的用户，你的帐号已经创建成功。"
			redirect_to root_url
		end
	end
end
