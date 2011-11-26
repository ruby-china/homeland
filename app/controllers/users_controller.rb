# coding: utf-8  
class UsersController < ApplicationController
  before_filter :require_user, :only => "auth_unbind"
  before_filter :init_base_breadcrumb
  before_filter :set_menu_active
  
  def index
    @total_user_count = User.count
    drop_breadcrumb t("common.index")
  end
  
  def show
    @user = User.where(:login => /^#{params[:id]}$/i).first
    @last_topics = @user.topics.recent.limit(20)          
    @last_replies = @user.replies.only(:topic_id, :body, :created_at).recent.includes(:topic).limit(10)
    set_seo_meta("#{@user.login}")
    drop_breadcrumb(@user.login)
  end
  
  def auth_unbind
    provider = params[:provider]
    if current_user.authorizations.count <= 1
      redirect_to edit_user_registration_path, :flash => {:error => t("users.unbind_warning")}
      return
    end
    
    current_user.authorizations.destroy_all(:conditions => {:provider => provider})
    redirect_to edit_user_registration_path, :flash => {:warring => t("users.unbind_success", :provider => provider.titleize )}
  end
  
  protected
  
  def set_menu_active
    @current = @current = ['/users']
  end
  
  def init_base_breadcrumb
    drop_breadcrumb( t("menu.users"), users_path)
  end
  
end
