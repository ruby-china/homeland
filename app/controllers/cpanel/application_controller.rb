# coding: utf-8
class Cpanel::ApplicationController < ApplicationController
  layout "cpanel"
  before_filter :require_user
  before_filter :require_admin

  def require_admin
    if not Setting.admin_emails.include?(current_user.email)
      render_404
    end
  end
end
