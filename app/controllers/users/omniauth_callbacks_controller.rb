# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  User.omniauth_providers.each do |provider|
    self.send(:define_method, provider) do
      process_callback
    end
  end

  if Rails.env.development?
    # File 'lib/devise/controllers/helpers.rb', line 254

    # def handle_unverified_request
    #   super # call the default behaviour which resets/nullifies/raises
    #   request.env["devise.skip_storage"] = true
    #   sign_out_all_scopes(false)
    # end

    # TODO 生产环境没事，开发环境总是会触发这个方法，走登录流程的时候读取到的是这个类ProtectionMethods::NullSession::NullSessionHash，无法完成第三方登录的流程。
    define_method :handle_unverified_request do
    end
  end

  def failure
    set_flash_message! :alert, :failure, kind: Homeland::Utils.omniauth_name(failed_strategy.name), reason: failure_message

    redirect_to new_user_session_path
  end

    private
      def process_callback
        if omniauth_auth.blank?
          redirect_to(new_user_session_path) && (return)
        end

        @user = User.find_or_create_by_omniauth(omniauth_auth)
        if @user&.persisted?
          # Sign in @user when exists binding or successfully created a user with binding
          sign_in_and_redirect @user, event: :authentication
        else
          # Otherwice (username/email has been used or not match with User validation)
          # Save auth info to Session and showup the Sign up/Sign in form for manual binding account.
          if @user
            set_flash_message! :alert, :failure, kind: Homeland::Utils.omniauth_name(omniauth_auth["provider"]), reason: @user.errors.full_messages.first
          end

          session[:omniauth] = omniauth_auth
          redirect_to new_user_registration_path
        end
      end

      def omniauth_auth
        return @omniauth_auth if defined? @omniauth_auth
        auth = request.env["omniauth.auth"]

        login = auth.info&.login
        if login.blank? && auth.info&.email
          login = auth.info&.email.split("@").first
        end

        @omniauth_auth = {
          "provider" => auth.provider,
          "uid" => auth.uid,
          "info" => {
            "name" => auth.info&.name,
            "login" => login,
            "image" => auth.info&.image,
            "email" => auth.info&.email
          }
        }
      end
  end
