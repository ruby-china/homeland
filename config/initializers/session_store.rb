# Be sure to restart your server when you modify this file.

# Rails.application.config.session_store :cookie_store, key: '_homeland_session'
redis_config = Rails.application.config_for(:redis)
Rails.application.config.session_store :redis_session_store, {
  key: '_homeland_session',
  redis: {
    expire_after: 60.days,
    key_prefix: 'rc:session',
    url: "redis://#{redis_config['host']}:#{redis_config['port']}/0",
  }
}
