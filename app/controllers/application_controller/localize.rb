# frozen_string_literal: true

class ApplicationController
  module Localize
    extend ActiveSupport::Concern

    included do
      helper_method :user_locale

      around_action :set_time_zone
      before_action :set_locale
    end

    def user_locale
      params[:locale] || cookies[:locale] || http_head_locale || Setting.default_locale || I18n.default_locale
    end

    def http_head_locale
      return nil unless Setting.auto_locale?
      http_accept_language.language_region_compatible_from(I18n.available_locales)
    end

    private

    def set_time_zone(&block)
      tz = Setting.timezone
      begin
        ActiveSupport::TimeZone.find_tzinfo(tz)
      rescue
        tz = "UTC"
      end
      Time.use_zone(tz, &block)
    end

    def set_locale
      I18n.locale = user_locale

      # after store current locale
      cookies[:locale] = params[:locale] if params[:locale]
    rescue I18n::InvalidLocale
      I18n.locale = I18n.default_locale
    end
  end
end
