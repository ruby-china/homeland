# frozen_string_literal: true

module Homeland
  class Utils
    class << self
      # Get camelize name for OmniAuth provider
      # LDAP -> Setting.ldap_title
      # Other -> OmniAuth::Utils.camelize
      def omniauth_camelize(provider)
        provider = provider.to_s

        case provider
        when "ldap"
          Setting.ldap_name
        when "google_oauth2"
          "Google"
        else
          OmniAuth::Utils.camelize(provider)
        end
      end
    end
  end
end
