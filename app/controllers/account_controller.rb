# coding: utf-8
# Devise User Controller
class AccountController < Devise::RegistrationsController
  protect_from_forgery

  def edit
    @user = current_user
    # 首次生成用户 Token
    @user.update_private_token if @user.private_token.blank?
  end

  def update
    super
  end

  # POST /resource
  def create
    build_resource(sign_up_params)
    resource.login = params[resource_name][:login]
    resource.email = params[resource_name][:email]
    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def destroy
    current_password = params[:user].try(:[], :current_password)
    if current_user.valid_password?(current_password)
      resource.soft_delete
      sign_out_and_redirect('/login')
      set_flash_message :notice, :destroyed
    else
      if current_password.present?
        current_user.valid?
        current_user.errors.add(:current_password, :invalid)
      end
    end
  end
end
