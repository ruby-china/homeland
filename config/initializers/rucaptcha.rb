# frozen_string_literal: true

redis_config = Rails.application.config_for(:redis)
RuCaptcha.configure do
  self.cache_store = [:redis_cache_store, {namespace: "rucaptcha", url: redis_config["url"], expires_in: 1.day}]
end

Recaptcha.configure do |config|
  config.api_server_url = "https://recaptcha.net/recaptcha/api.js"
  config.verify_url = "https://recaptcha.net/recaptcha/api/siteverify"
end

module ComplexCaptchaHelper
  def verify_complex_captcha?(resource = nil, opts = {})
    return true unless Setting.captcha_enable?

    if Setting.use_recaptcha?
      verify_recaptcha(model: resource, secret_key: Setting.recaptcha_secret)
    else
      verify_rucaptcha?(resource)
    end
  end
end

ActionController::Base.send :include, ComplexCaptchaHelper
