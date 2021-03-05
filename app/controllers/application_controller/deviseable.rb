# frozen_string_literal: true

class ApplicationController
  module Deviseable
    extend ActiveSupport::Concern

    included do
      before_action :configure_permitted_parameters, if: :devise_controller?
    end

    def store_location
      session[:return_to] = request.url
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    def redirect_referrer_or_default(default)
      redirect_to(request.referrer || default)
    end

    def authenticate_user!(opts = {})
      return if current_user
      if turbolinks_app?
        render plain: "401 Unauthorized", status: 401
        return
      end

      store_location

      super(opts)
    end

    def current_user
      if doorkeeper_token
        return @current_user if defined? @current_user
        @current_user ||= User.find_by_id(doorkeeper_token.resource_owner_id)
        sign_in @current_user
        @current_user
      else
        super
      end
    end

    def require_no_sso!
      redirect_to auth_sso_path if Setting.sso_enabled?
    end

    private

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: %i[login name email email_public omniauth_provider omniauth_uid])
      devise_parameter_sanitizer.permit(:sign_in, keys: %i[login password remember_me])
    end
  end
end
