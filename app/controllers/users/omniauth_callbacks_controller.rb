class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def self.provides_callback_for(*providers)
    providers.each do |provider|
      class_eval %Q{
        def #{provider}
          @user = User.find_or_create_for_#{provider}(env["omniauth.auth"])
        
          if @user.persisted?
            flash[:notice] = "Signed in with #{provider.to_s.titleize} successfully."
            sign_in_and_redirect @user, :event => :authentication
          else
            session["devise.auth_data"] = env["omniauth.auth"]
            redirect_to new_user_registration_url
          end
        end
      }
    end
  end
  
  provides_callback_for :github, :twitter, :douban, :google


end