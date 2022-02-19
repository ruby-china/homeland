# frozen_string_literal: true

Rails.application.config.to_prepare do
  limit_value = Setting.rack_attack[:limit].to_s.to_i
  period_value = Setting.rack_attack[:period].to_s.to_i || 5.minutes
  block_message = ["你请求过快，超过了频率限制，暂时屏蔽一段时间。"]
  Rack::Attack.cache.store = Rails.cache

  if limit_value > 0
    ### Throttle Spammy Clients ###
    Rack::Attack.throttle("req/ip", limit: limit_value, period: period_value) do |req|
      req.ip
    end

    # 固定黑名单
    Rack::Attack.blocklist("blacklist/ip") do |req|
      Setting.blacklist_ips && !Setting.blacklist_ips.index(req.ip).nil?
    end

    # 允许 localhost
    # Rack::Attack.safelist("allow from localhost") do |req|
    #   req.ip == "127.0.0.1" || req.ip == "::1"
    # end

    ### Custom Throttle Response ###
    Rack::Attack.throttled_response = lambda do |env|
      [503, {}, block_message]
    end

    ActiveSupport::Notifications.subscribe("track.rack_attack") do |name, start, finish, request_id, payload|
      req = payload[:request]
      Rails.logger.info "  RackAttack: #{req.ip} #{request_id} blocked."
    end
  end
end
