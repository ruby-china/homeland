# frozen_string_literal: true

class ApplicationController
  module Turbolinks
    extend ActiveSupport::Concern

    included do
      helper_method :turbolinks_app?, :turbolinks_ios?, :turbolinks_app_version
    end

    def turbolinks_app?
      @turbolinks_app ||= request.user_agent.to_s.include?("turbolinks-app")
    end

    def turbolinks_ios?
      @turbolinks_ios ||= turbolinks_app? && request.user_agent.to_s.include?("iOS")
    end

    # read turbolinks app version
    # example: version:2.1
    def turbolinks_app_version
      return "" unless turbolinks_app?
      return @turbolinks_app_version if defined? @turbolinks_app_version
      version_str = request.user_agent.to_s.match(/version:[\d.]+/).to_s
      @turbolinks_app_version = version_str.split(":").last
      @turbolinks_app_version
    end
  end
end
