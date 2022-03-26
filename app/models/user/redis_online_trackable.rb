# frozen_string_literal: true

# Track user online status
class User
  module RedisOnlineTrackable
    extend ActiveSupport::Concern

    REDIS_ONLINE_KEY = "online_users_set"

    # Track user online timestamp
    # Example: Invoke `current_user.touch_last_online_ts` in a controller request.
    def touch_last_online_ts(timestamp: Time.current)
      Redis.current.zadd(REDIS_ONLINE_KEY, timestamp.to_i, id)
    end

    def last_online_at
      last_online_ts = Redis.current.zscore(REDIS_ONLINE_KEY, id)
      Time.at(last_online_ts) if last_online_ts
    end

    def online?(timeout: 300)
      if last_online_at
        return Time.current - last_online_at < timeout
      end
      false
    end

    class_methods do
      # @duration: past time, use second unit.
      def online_users_count(duration: 300)
        now_ts = Time.current.to_i
        past_ts = now_ts - duration
        Redis.current.zcount(REDIS_ONLINE_KEY, past_ts, now_ts + 5)
      end

      def cleanup_inactive_online_stats(past_datetime: 1.weeks.ago)
        past_ts = past_datetime.to_i
        Redis.current.zremrangebyscore(REDIS_ONLINE_KEY, 0, past_ts)
      end
    end
  end
end
