class SessionsController < Devise::SessionsController
  prepend_before_action :valify_captcha!, only: [:create], if: :display_login_captcha?
  skip_before_action :set_locale, only: [:create]

  def new
    super
    cache_referrer
  end

  def create
    increase_login_counter
    resource = warden.authenticate!(scope: resource_name, recall: "#{controller_path}#new")
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    delete_login_counter
    respond_to do |format|
      format.html { redirect_to after_sign_in_path_for(resource) }
      format.json { render status: '201', json: resource.as_json(only: [:login, :email]) }
    end
  end

  def valify_captcha!
    set_locale
    unless verify_rucaptcha?
      redirect_to new_user_session_path, alert: t('rucaptcha.invalid')
      return
    end
    true
  end

  private

  def cache_referrer
    referrer = request.referrer
    # Ignore other site url and user sign in url.
    if referrer && referrer.include?(domain_or_host) && referrer.exclude?(new_user_session_path)
      session['user_return_to'] = request.referrer
    end
  end

  # If not bind to a domain, request.domain is nil.
  def domain_or_host
    request.domain || request.host
  end

  def increase_login_counter
    session[:_rucaptcha_logins] ||= 0
    session[:_rucaptcha_logins] += 1
  end

  def delete_login_counter
    session.delete(:_rucaptcha_logins)
  end

  def display_login_captcha?
    session[:_rucaptcha_logins] && session[:_rucaptcha_logins] >= 3
  end

  helper_method :display_login_captcha?
end
