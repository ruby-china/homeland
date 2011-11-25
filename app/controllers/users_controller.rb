# coding: utf-8  
class UsersController < ApplicationController
  before_filter :require_user, :only => "auth_unbind"
  before_filter :init_base_breadcrumb
  before_filter :set_menu_active
  
  def index
    @total_user_count = User.count
    drop_breadcrumb("目录")
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
      redirect_to edit_user_registration_path, :flash => {:error => "只少要保留一个关联帐号，现在不能解绑。"}
      return
    end
    
    current_user.authorizations.destroy_all(:conditions => {:provider => provider})
    redirect_to edit_user_registration_path, :flash => {:warring => "#{provider.titleize} 帐号解绑成功。"}
  end
  
  protected
  
  def set_menu_active
    @current = @current = ['/users']
  end
  
  def init_base_breadcrumb
    drop_breadcrumb("会员", users_path)
  end
  
end
