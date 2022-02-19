Rails.application.config.to_prepare do
  ActionMailer::Base.default_url_options = {host: Setting.domain, protocol: Setting.protocol}
end
