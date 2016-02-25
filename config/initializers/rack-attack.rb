BLOCK_MESSAGE = ['你请求过快，超过了频率限制，暂时屏蔽一段时间。如果有问题，请到 https://github.com/ruby-china/ruby-china/issues/new 提出。'.freeze]

class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::DalliStore.new("127.0.0.1")

  ### Throttle Spammy Clients ###
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?('/mini-profiler-resources')
  end

  # 登陆保护
  throttle('oauth/token/ip', limit: 5, period: 20.seconds) do |req|
    if req.path.start_with?('/oauth/token')
      req.ip
    end
  end

  # 固定黑名单
  blacklist("blacklist/ip") do |req|
    SiteConfig.blacklist_ips.index(req.ip) != nil
  end

  # 允许 localhost
  whitelist('allow from localhost') do |req|
    # '127.0.0.1' == req.ip || '::1' == req.ip
  end

  ### Custom Throttle Response ###
  self.throttled_response = lambda do |env|
    [ 503, {}, BLOCK_MESSAGE]
  end
end

ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, req|
  Rails.logger.info "  RackAttack: #{req.ip} #{request_id} blocked."
end
