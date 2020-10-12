# frozen_string_literal: true

module Homeland
  class Utils
    class << self
      # Get name for OmniAuth provider
      # Other -> OmniAuth::Utils.camelize
      def omniauth_name(provider)
        provider = provider.to_s

        case provider
        when "wechat"
          "微信"
        else
          OmniAuth::Utils.camelize(provider)
        end
      end

      def icon(provider)
      end
    end
  end
end
