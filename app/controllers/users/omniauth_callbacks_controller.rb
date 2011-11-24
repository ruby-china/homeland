class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def self.provides_callback_for(*providers)
    providers.each do |provider|
      class_eval %Q{
        def #{provider}

          @user = User.find_or_create_for_#{provider}(env["omniauth.auth"])
          flash[:notice] = "Signed in with #{provider.to_s.titleize} successfully."
          sign_in_and_redirect @user, :event => :authentication
        end
      }
    end
  end
  
  provides_callback_for :github
end