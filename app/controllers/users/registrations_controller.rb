# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :require_no_sso!, only: %i[new create]

  # POST /resource
  def create
    cache_key = ["user-sign-up", request.remote_ip, Date.today]
    # IP limit
    sign_up_count = Rails.cache.read(cache_key) || 0
    setting_limit = Setting.sign_up_daily_limit
    if setting_limit > 0 && sign_up_count >= setting_limit
      message = "You not allow to sign up new Account, because your IP #{request.remote_ip} has over #{setting_limit} times in today."
      logger.warn message
      return render status: 403, plain: message
    end

    build_resource(sign_up_params)

    unless verify_complex_captcha?(resource)
      Rails.cache.write(cache_key, sign_up_count + 1)
      clean_up_passwords resource
      respond_with resource
      return
    end

    resource.save
    yield resource if block_given?
    if resource.persisted?
      session[:omniauth] = nil
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def after_inactive_sign_up_path_for(resource_or_scope)
    new_user_session_path
  end
end
