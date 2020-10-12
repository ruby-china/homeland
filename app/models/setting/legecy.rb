# frozen_string_literal: true

class Setting
  module Legecy
    extend ActiveSupport::Concern

    LEGECY_ENVS = {
      github_token: "github_api_key",
      github_secret: "github_api_secret",
    }

    included do
    end

    module ClassMethods
      def legecy_env_instead(key)
        LEGECY_ENVS[key]
      end

      def legecy_envs
        keys = []
        LEGECY_ENVS.each_key do |key|
          keys << key if ENV[key.to_s].present?
        end
        keys
      end
    end
  end
end
