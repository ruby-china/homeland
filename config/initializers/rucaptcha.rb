# frozen_string_literal: true

memcached_config = Rails.application.config_for(:memcached)
RuCaptcha.configure do
  self.cache_store = [:mem_cache_store, memcached_config["host"], memcached_config]
end
