# frozen_string_literal: true

# ApplicationController
class ApplicationController < ActionController::Base
  include Localize
  include Deviseable
  include CurrentInfo
  include Turbolinks
  include UserNotifications

  protect_from_forgery prepend: true
  fragment_cache_key { user_locale }

  # Addition contents for etag
  etag { current_user.try(:id) }
  etag { unread_notify_count }
  etag { flash }
  etag { Setting.navbar_html }
  etag { Setting.footer_html }
  etag { Rails.env.development? ? Time.now : Date.current }

  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.json { head :not_found }
      format.html { render "/errors/404", status: :not_found }
    end
  end

  before_action do
    cookies.signed[:user_id] ||= current_user.try(:id)

    # hit unread_notify_count
    unread_notify_count
  end

  before_action :set_active_menu
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
    fname = %w[404 403 422 500].include?(status) ? status : "unknown"

    respond_to do |format|
      format.html { render template: "/errors/#{fname}", handler: [:erb], status: status, layout: "application" }
      format.all { render body: nil, status: status }
    end
  end

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to main_app.root_path, alert: t("common.access_denied")
  end

  def prefetch?
    request.headers["Purpose"] == "prefetch"
  end

  # Require Setting enabled module, else will render 404 page.
  def self.require_module_enabled!(name)
    before_action do
      unless Setting.has_module?(name)
        render_404
      end
    end
  end
end
