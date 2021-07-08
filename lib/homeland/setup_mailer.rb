module Homeland
  # Improve ActionMailer::Base configuration for support reload from Setting.
  module SetupMailer
    extend ActiveSupport::Concern

    class_methods do
      def delivery_method
        case Rails.env
        when "test"
          :test
        else
          Setting.mailer_provider.to_sym
        end
      end

      def default_url_options
        {host: Setting.domain, protocol: Setting.protocol}
      end

      def default_options
        {from: Setting.mailer_sender, charset: "utf-8", content_type: "text/html"}
      end

      def postmark_settings
        Setting.mailer_options.slice(:api_key).deep_symbolize_keys
      end

      def smtp_settings
        Setting.mailer_options.slice(:address, :port, :domain, :user_name, :password, :authentication, :enable_starttls_auto).deep_symbolize_keys
      end
    end
  end
end
