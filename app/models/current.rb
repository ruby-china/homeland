# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :request_id
  attribute :user

  def self.redis
    return @_redis if @_redis.present?

    redis_config = Rails.application.config_for(:redis)

    @_redis = Redis.new(url: redis_config["url"], db: 0)
  end
end
