# frozen_string_literal: true

if Setting.rack_attack.present?
  BLOCK_MESSAGE = ["你请求过快，超过了频率限制，暂时屏蔽一段时间。"]

  class Rack::Attack
    Rack::Attack.cache.store = Rails.cache

    ### Throttle Spammy Clients ###
    throttle("req/ip", limit: Setting.rack_attack["limit"] || 300, period: Setting.rack_attack["period"] || 3.minutes, &:ip)

    # 固定黑名单
    blocklist("blacklist/ip") do |req|
      Setting.blacklist_ips && !Setting.blacklist_ips.index(req.ip).nil?
    end

    # 允许 localhost
    safelist("allow from localhost") do |req|
      req.ip == "127.0.0.1" || req.ip == "::1"
    end

    ### Custom Throttle Response ###
    self.throttled_response = lambda do |_env|
      [503, {}, BLOCK_MESSAGE]
    end
  end

  ActiveSupport::Notifications.subscribe("rack.attack") do |_name, _start, _finish, request_id, req|
    Rails.logger.info "  RackAttack: #{req.ip} #{request_id} blocked."
  end
end
