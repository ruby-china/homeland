# coding: utf-8
class Cpanel::ApplicationController < ApplicationController
  layout "cpanel"
  before_action :require_user
  before_action :require_admin
  before_action :set_active_menu

  def require_admin
    if not Setting.admin_emails.include?(current_user.email)
      render_404
    end
  end
  
  def set_active_menu
    @current = ["/" + ["cpanel",controller_name].join("/")]
  end
  
end
