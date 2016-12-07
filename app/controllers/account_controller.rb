# Devise User Controller
class AccountController < Devise::RegistrationsController
  def edit
    @user = current_user
  end

  def update
    super
  end

  # POST /resource
  def create
    build_resource(sign_up_params)
    resource.login = params[resource_name][:login]
    resource.email = params[resource_name][:email]
    if verify_rucaptcha?(resource) && resource.save
      sign_in(resource_name, resource)
    end
  end

  def destroy
    current_password = params[:user][:current_password]

    if current_user.valid_password?(current_password)
      resource.soft_delete
      sign_out
      redirect_to root_path
      set_flash_message :notice, :destroyed
    else
      current_user.errors.add(:current_password, :invalid)
      render 'edit'
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
