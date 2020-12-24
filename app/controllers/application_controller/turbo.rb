# frozen_string_literal: true

class ApplicationController
  module Turbo
    extend ActiveSupport::Concern

    included do
      helper_method :turbo_app?, :turbo_ios?, :turbo_app_version
    end

    def turbo_app?
      @turbo_app ||= request.user_agent.to_s.include?("turbolinks-app")
    end

    def turbo_ios?
      @turbo_ios ||= turbo_app? && request.user_agent.to_s.include?("iOS")
    end

    # read turbolinks app version
    # example: version:2.1
    def turbo_app_version
      return "" unless turbo_app?
      return @turbo_app_version if defined? @turbo_app_version
      version_str = request.user_agent.to_s.match(/version:[\d\.]+/).to_s
      @turbo_app_version = version_str.split(":").last
      @turbo_app_version
    end
  end
end
