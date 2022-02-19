# frozen_string_literal: true

Rails.application.config.to_prepare do
  Doorkeeper.configure do
    # Change the ORM that doorkeeper will use.
    # Currently supported options are :active_record, :mongoid2, :mongoid3,
    # :mongoid4, :mongo_mapper
    orm :active_record

    # This block will be called to check whether the resource owner is authenticated or not.
    resource_owner_authenticator do
      current_user || redirect_to(new_user_session_url)
    end

    resource_owner_from_credentials do
      request.params[:user] = {login: request.params[:username], password: request.params[:password]}
      request.env["devise.allow_params_authentication"] = true
      # 清理之前的 warden 信息
      request.env["warden"].logout(:user)
      resource = request.env["warden"].authenticate(scope: :user)
      resource
    end

    # If you want to restrict access to the web interface for adding oauth authorized applications, you need to declare the block below.
    admin_authenticator do
      current_user
    end

    # Authorization Code expiration time (default 10 minutes).
    # authorization_code_expires_in 10.minutes

    # Access token expiration time (default 2 hours).
    # If you want to disable expiration, set this to nil.
    access_token_expires_in 1.days

    # Assign a custom TTL for implicit grants.
    custom_access_token_expires_in do |context|
      application = context.client.is_a?(Doorkeeper::Application) ? context.client : context.client&.application
      case application&.level
      when 1 then 7.days
      when 2 then 14.days
      when 3 then 30.days
      else
        1.days
      end
    end

    # Use a custom class for generating the access token.
    # https://github.com/doorkeeper-gem/doorkeeper#custom-access-token-generator
    # access_token_generator "::Doorkeeper::JWT"

    # Reuse access token for the same resource owner within an application (disabled by default)
    # Rationale: https://github.com/doorkeeper-gem/doorkeeper/issues/383
    # reuse_access_token

    # Issue access tokens with refresh token (disabled by default)
    use_refresh_token

    # Provide support for an owner to be assigned to each registered application (disabled by default)
    # Optional parameter :confirmation => true (default false) if you want to enforce ownership of
    # a registered application
    # Note: you must also run the rails g doorkeeper:application_owner generator to provide the necessary support
    enable_application_owner confirmation: true

    # Define access token scopes for your provider
    # For more information go to
    # https://github.com/doorkeeper-gem/doorkeeper/wiki/Using-Scopes
    default_scopes :all
    # optional_scopes :write, :update

    # Change the way client credentials are retrieved from the request object.
    # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
    # falls back to the `:client_id` and `:client_secret` params from the `params` object.
    # Check out the wiki for more information on customization
    # client_credentials :from_basic, :from_params

    # Change the way access token is authenticated from the request object.
    # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
    # falls back to the `:access_token` or `:bearer_token` params from the `params` object.
    # Check out the wiki for more information on customization
    # access_token_methods :from_bearer_authorization, :from_access_token_param, :from_bearer_param

    # Forces the usage of the HTTPS protocol in non-native redirect uris (enabled
    # by default in non-development environments). OAuth2 delegates security in
    # communication to the HTTPS protocol so it is wise to keep this enabled.
    #
    force_ssl_in_redirect_uri false

    # Specify what grant flows are enabled in array of Strings. The valid
    # strings and the flows they enable are:
    #
    # "authorization_code" => Authorization Code Grant Flow
    # "implicit"           => Implicit Grant Flow
    # "password"           => Resource Owner Password Credentials Grant Flow
    # "client_credentials" => Client Credentials Grant Flow
    #
    # If not specified, Doorkeeper enables authorization_code and
    # client_credentials.
    #
    # implicit and password grant flows have risks that you should understand
    # before enabling:
    #   http://tools.ietf.org/html/rfc6819#section-4.4.2
    #   http://tools.ietf.org/html/rfc6819#section-4.4.3
    #
    # grant_flows %w(authorization_code client_credentials)
    grant_flows %w[authorization_code client_credentials password]

    # Under some circumstances you might want to have applications auto-approved,
    # so that the user skips the authorization step.
    # For example if dealing with a trusted application.
    # skip_authorization do |resource_owner, client|
    #   client.superapp? or resource_owner.admin?
    # end

    # WWW-Authenticate Realm (default "Doorkeeper").
    realm Setting.app_name
  end
end

# https://github.com/doorkeeper-gem/doorkeeper/issues/1467
# HOTFIX: find_access_token_in_batches with Ruby 3.0
Doorkeeper::AccessTokenMixin::ClassMethods.module_eval do
  def find_access_token_in_batches(relation, **args, &block)
    relation.find_in_batches(**args, &block)
  end
end
