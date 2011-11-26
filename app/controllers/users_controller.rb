# coding: utf-8  
class UsersController < ApplicationController
  before_filter :require_user, :only => "auth_unbind"
  before_filter :init_base_breadcrumb
  before_filter :set_menu_active
  before_filter :find_user, :only => [:show, :replies, :likes]
  
  def index
    @total_user_count = User.count
    drop_breadcrumb("目录")
  end
  
  def show
    @topics = @user.topics.recent.paginate(:page => params[:page], :per_page => 20)          
    set_seo_meta("#{@user.login}")
    drop_breadcrumb(@user.login)
  end
  
  def replies
    @replies = @user.replies.only(:topic_id, :body, :created_at).recent.includes(:topic).limit(10)
    drop_breadcrumb(@user.login, user_path(@user.login))
    drop_breadcrumb("回帖")
  end
  
  def likes
    @likes = @user.likes.recent.topics.paginate(:page => params[:page], :per_page => 20)
    drop_breadcrumb(@user.login, user_path(@user.login))
    drop_breadcrumb("喜欢")
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
  def find_user
    @user = User.where(:login => /^#{params[:id]}$/i).first
  end
  
  def set_menu_active
    @current = @current = ['/users']
  end
  
  def init_base_breadcrumb
    drop_breadcrumb("会员", users_path)
  end
  
end
