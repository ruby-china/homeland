# frozen_string_literal: true

# notifications Config
Notifications.configure do
  # Class name of you User model, default: 'User'
  # self.user_class = 'User'

  # Method of user name in User model, default: 'name'
  self.user_name_method = "login"

  # Method of user avatar in User model, default: nil
  self.user_avatar_url_method = "large_avatar_url"

  # Method name of user profile page path, in User model, default: 'profile_url'
  self.user_profile_url_method = "profile_url"

  # authenticate_user method in your Controller, default: 'authenticate_user!'
  # If you use Devise, authenticate_user! is correct
  self.authenticate_user_method = "authenticate_user!"

  # current_user method name in your Controller, default: 'current_user'
  # If you use Devise, current_user is correct
  # self.current_user_method = 'current_user'
end
