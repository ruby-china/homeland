# frozen_string_literal: true

# Devise User Controller
class AccountController < Devise::RegistrationsController
  before_action :require_no_sso!, only: %i[new create]

  def new
    super
  end

  def edit
    redirect_to setting_path
  end

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
    resource.login = params[resource_name][:login]
    resource.email = params[resource_name][:email]
    if verify_complex_captcha?(resource) && resource.save
      Rails.cache.write(cache_key, sign_up_count + 1)

      sign_in(resource_name, resource)
    end
  end

  private

    # Overwrite the default url to be used after updating a resource.
    # It should be edit_user_registration_path
    # Note: resource param can't miss, because it's the super caller way.
    def after_update_path_for(_)
      edit_user_registration_path
    end
end
