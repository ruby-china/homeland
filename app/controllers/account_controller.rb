class AccountController < Devise::RegistrationsController
  def destroy
    logger.debug { "---------------- AccountController" }
    resource.soft_delete
    sign_out_and_redirect("/login")
    set_flash_message :notice, :destroyed
  end
end