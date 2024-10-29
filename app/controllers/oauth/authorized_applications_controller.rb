module Oauth
  class AuthorizedApplicationsController < Doorkeeper::ApplicationController
    before_action :authenticate_resource_owner!

    def destroy
      Doorkeeper::AccessToken.revoke_all_for params[:id].to_i, current_resource_owner
      redirect_to oauth_applications_url, notice: I18n.t(:notice, scope: %i[doorkeeper flash authorized_applications destroy])
    end
  end
end
