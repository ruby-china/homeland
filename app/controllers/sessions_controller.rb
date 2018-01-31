class SessionsController < Devise::SessionsController
  skip_before_action :set_locale, only: [:create]
  before_action :require_no_sso!, only: %i[new create]

  def create
    resource = warden.authenticate!(scope: resource_name, recall: "#{controller_path}#new")
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    respond_to do |format|
      format.html { redirect_back_or_default(root_url) }
      format.json { render status: "201", json: resource.as_json(only: %i[login email]) }
    end
  end

  private

  # If not bind to a domain, request.domain is nil.
  def domain_or_host
    request.domain || request.host
  end

  def respond_to_on_destroy
    redirect_to topics_url
  end
end
