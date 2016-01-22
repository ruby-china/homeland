module Cpanel
  class ApplicationController < ::ApplicationController
    layout 'cpanel'

    before_action :require_user
    before_action :require_admin
    before_action :set_active_menu

    def require_admin
      render_404 unless current_user.admin?
    end

    def set_active_menu
      @current = ['/' + ['cpanel', controller_name].join('/')]
    end
  end
end
