# coding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :unread_notify_count

  before_filter do    
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
    
    if devise_controller?      
      devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(*User::ACCESSABLE_ATTRS) }
      devise_parameter_sanitizer.for(:account_update) { |u| u.permit(*User::ACCESSABLE_ATTRS) }
      devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(*User::ACCESSABLE_ATTRS) }
    end
  end

  def render_404
    render_optional_error_file(404)
  end

  def render_403
    render_optional_error_file(403)
  end

  def render_optional_error_file(status_code)
    status = status_code.to_s
    if ["404","403", "422", "500"].include?(status)
      render :template => "/errors/#{status}", :format => [:html], :handler => [:erb], :status => status, :layout => "application"
    else
      render :template => "/errors/unknown", :format => [:html], :handler => [:erb], :status => status, :layout => "application"
    end
  end

  def drop_breadcrumb(title=nil, url=nil)
    title ||= @page_title
    url ||= url_for
    if title
      @breadcrumbs.push(%(<a href="#{url}" itemprop="url"><span itemprop="title">#{title}</span></a>).html_safe)
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to topics_path, :alert => t("common.access_denied")
  end

  def notice_success(msg)
    flash[:notice] = msg
  end

  def notice_error(msg)
    flash[:notice] = msg
  end

  def notice_warning(msg)
    flash[:notice] = msg
  end

  def set_seo_meta(title = '',meta_keywords = '', meta_description = '')
    if title.length > 0
      @page_title = "#{title}"
    end
    @meta_keywords = meta_keywords
    @meta_description = meta_description
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def redirect_referrer_or_default(default)
    redirect_to(request.referrer || default)
  end

  def require_user
    if current_user.blank?
      respond_to do |format|
        format.html  {
          authenticate_user!
        }
        format.all {
          head(:unauthorized)
        }
      end
    end
  end
  
  def unread_notify_count
    return 0 if current_user.blank?
    @unread_notify_count ||= current_user.notifications.unread.count
  end
  
  def fresh_when(opts = {})
    opts[:etag] ||= []
    # 保证 etag 参数是 Array 类型
    opts[:etag] = [opts[:etag]] if !opts[:etag].is_a?(Array)
    # 加入页面上直接调用的信息用于组合 etag
    opts[:etag] << current_user
    # Config 的某些信息
    opts[:etag] << Setting.app_name
    opts[:etag] << SiteConfig.custom_head_html
    opts[:etag] << SiteConfig.footer_html
    opts[:etag] << SiteConfig.faye_server
    opts[:etag] << Setting.google_analytics_key
    # 加入通知数量
    opts[:etag] << unread_notify_count
    # 所有 etag 保持一天
    opts[:etag] << Date.current
    opts[:etag] << Time.now if not Rails.env.production?
    super(opts)
  end
end
