BLOCK_MESSAGE = ['你请求过快，超过了频率限制，暂时屏蔽一段时间。如果有问题，请到 https://github.com/ruby-china/ruby-china/issues/new 提出。'.freeze]

class Rack::Attack
  Rack::Attack.cache.store = Rails.cache

  ### Throttle Spammy Clients ###
  throttle('req/ip', limit: 500, period: 3.minutes) do |req|
    req.ip unless req.path.start_with?('/mini-profiler-resources')
  end

  # 固定黑名单
  blocklist('blacklist/ip') do |req|
    Setting.blacklist_ips && !Setting.blacklist_ips.index(req.ip).nil?
  end

  # 允许 localhost
  safelist('allow from localhost') do |req|
    # '127.0.0.1' == req.ip || '::1' == req.ip
  end

  ### Custom Throttle Response ###
  self.throttled_response = lambda do |_env|
    [503, {}, BLOCK_MESSAGE]
  end
end

ActiveSupport::Notifications.subscribe('rack.attack') do |_name, _start, _finish, request_id, req|
  Rails.logger.info "  RackAttack: #{req.ip} #{request_id} blocked."
end
