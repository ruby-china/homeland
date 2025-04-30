class Users::SessionsController < Devise::SessionsController
  before_action :require_no_sso!, only: %i[new create]

  def create
    resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?

    if session[:omniauth]
      @auth = Authorization.find_or_create_by!(provider: session[:omniauth]["provider"], uid: session[:omniauth]["uid"], user_id: resource.id)
      if @auth.blank?
        redirect_to new_user_session_path, alter: "Sign in and bind OAuth account failed."
        return
      end

      set_flash_message(:notice, "Sign in successfully with bind #{Homeland::Utils.omniauth_name(session[:omniauth]["provider"])}")
      session[:omniauth] = nil
    end

    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_to do |format|
      format.html { redirect_back_or_default(root_url) }
      format.json { render status: "201", json: resource.as_json(only: %i[login email]) }
    end
  end

  def destroy
    Rails.logger.info "Destroying session for user: #{current_user&.id}"
    
    # Clean cookies
    cookies.delete(:user_id)
    cookies.delete(:remember_user_token)
    
    # Perform logout operation
    sign_out(current_user)
    
    # If SSO logout URL is set, redirect to that URL
    if ENV['sso_logout_url'].present?
      Rails.logger.info "Redirecting to SSO logout URL: #{ENV['sso_logout_url']}"
      redirect_to ENV['sso_logout_url'], allow_other_host: true
    else
      Rails.logger.info "Redirecting to root path"
      redirect_to root_path
    end
  rescue => e
    Rails.logger.error "Error during logout: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end
end
