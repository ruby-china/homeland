class SessionsController < Devise::SessionsController
  skip_before_action :set_locale, only: [:create]

  def new
    super
    cache_referrer
  end

  def create
    resource = warden.authenticate!(scope: resource_name, recall: "#{controller_path}#new")
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    respond_to do |format|
      format.html { redirect_to topics_url }
      format.json { render status: '201', json: resource.as_json(only: [:login, :email]) }
    end
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

  def respond_to_on_destroy
    redirect_to topics_url
  end
end
