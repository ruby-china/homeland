# coding: utf-8  
class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user_session, :current_user
  before_filter :init
  def init
    current_user
  end

  def render_404
    render_optional_error_file(404)
  end
  
  def render_optional_error_file(status_code)
    status = status_code.to_s
    if ["404", "422", "500"].include?(status)
      render :template => "/errors/#{status}.html.erb", :status => status, :layout => "application"
    else
      render :template => "/errors/unknown.html.erb", :status => status, :layout => "application"
    end
  end

  def notice_success(msg)
    flash[:notice] = msg
  end

  def notice_error(msg)
    flash[:notice] = msg
  end

  def notice_warring(msg)
    flash[:notice] = msg
  end

  def set_seo_meta(title = '',meta_keywords = '', meta_description = '')
    if title.length > 0
      @page_title = "#{title} &raquo; "
    end
    @meta_keywords = meta_keywords
    @meta_description = meta_description
  end
  
  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      # @current_user_session = UserSession.find
    end
    
    def current_user
      return @current_user if defined?(@current_user)
      @current_user = User.first # current_user_session && current_user_session.record
    end
    
    def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to login_path
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to root_path
        return false
      end
    end
    
    def store_location
      session[:return_to] = request.request_uri
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

end
