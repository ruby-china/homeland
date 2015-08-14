module Cpanel
  class ApplicationController < ::ApplicationController
    layout 'cpanel'
    before_action :require_user
    before_action :require_admin
    before_action :set_active_menu

    def require_admin
      render_404 unless Setting.admin_emails.include?(current_user.email)
    end

    def set_active_menu
      @current = ['/' + ['cpanel', controller_name].join('/')]
    end
  end
end
