# frozen_string_literal: true

module Auth
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def self.provides_callback_for(*providers)
      providers.each do |provider|
        self.send(:define_method, provider) do
          unless current_user.blank?
            # add an auth to existing
            current_user.bind_service(request.env["omniauth.auth"])
            redirect_to account_setting_path, notice: "成功绑定了 #{provider} 帐号。"
            return
          end

          @user = User.send("find_or_create_for_#{provider}", request.env["omniauth.auth"])
          if @user.persisted?
            flash[:notice] = t("devise.sessions.signed_in")
            sign_in_and_redirect @user, event: :authentication
          else
            redirect_to new_user_registration_url
          end
        end
      end
    end

    provides_callback_for :github, :twitter, :douban, :google

    # This is solution for existing accout want bind Google login but current_user is always nil
    # https://github.com/intridea/omniauth/issues/185
    def handle_unverified_request
      true
    end
  end
end
