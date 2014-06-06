# coding: utf-8
# ApplicationController
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
  
  before_filter :set_active_menu
  def set_active_menu
    @current = case controller_name
    when "pages"
      ["/wiki"]
    else
      ["/#{controller_name}"]
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
    fname = %W(404 403 422 500).include?(status) ? status : 'unknown'
    render template: "/errors/#{fname}", format: [:html],
           handler: [:erb], status: status, layout: 'application'
  end
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to topics_path, alert: t('common.access_denied')
  end
  
  def set_seo_meta(title = '', meta_keywords = '', meta_description = '')
    @page_title = "#{title}" if title.length > 0
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
        format.html { authenticate_user! }
        format.all { head(:unauthorized) }
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
    opts[:etag] = [opts[:etag]] unless opts[:etag].is_a?(Array)
    # 加入页面上直接调用的信息用于组合 etag
    opts[:etag] << current_user
    # Config 的某些信息
    opts[:etag] << SiteConfig.custom_head_html
    opts[:etag] << SiteConfig.footer_html
    # 加入通知数量
    opts[:etag] << unread_notify_count
    # 所有 etag 保持一天
    opts[:etag] << Date.current
    super(opts)
  end
end
