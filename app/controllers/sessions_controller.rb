class SessionsController < Devise::SessionsController
  prepend_before_filter :valify_captcha!, only: [:create]
  skip_before_action :set_locale, only: [:create]

  def new
    super
    session['user_return_to'] = request.referrer
  end

  def create
    resource = warden.authenticate!(scope: resource_name, recall: "#{controller_path}#new")
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    resource.ensure_private_token!
    respond_to do |format|
      format.html { redirect_to after_sign_in_path_for(resource) }
      format.json { render status: '201', json: resource.as_json(only: [:login, :email, :private_token]) }
    end
  end

  def valify_captcha!
    set_locale
    if !verify_rucaptcha?
      redirect_to new_user_session_path, alert: t('rucaptcha.invalid') and return
    end
    true
  end
end
