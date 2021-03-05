# frozen_string_literal: true

class Topic
  module RateLimit
    extend ActiveSupport::Concern

    included do
      before_validation :_rate_limit_create, on: :create
      after_commit :_log_rate_limit_create, on: :create
    end

    private

    def _rate_limit_key
      @rate_limit_key ||= "users:#{user_id}:topic-create"
    end

    def _rate_limit_hour_key
      @rate_limit_hour_key ||= "users:#{user_id}:topic-create-by-hour"
    end

    def _rate_limit_create
      if Rails.cache.read(_rate_limit_key)
        errors.add(:base, I18n.t("topics.create_too_frequently"))
      end

      count_limit = Setting.topic_create_hour_limit_count.to_i
      if count_limit > 0
        count = Rails.cache.read(_rate_limit_hour_key) || 0
        if count >= count_limit
          errors.add(:base, I18n.t("topics.create_limit", count: count_limit))
        end
      end
    end

    def _log_rate_limit_create
      limit_interval = Setting.topic_create_limit_interval.to_i
      if limit_interval > 0
        Rails.cache.write(_rate_limit_key, 1, expires_in: limit_interval)
      end

      count = Rails.cache.read(_rate_limit_hour_key) || 0
      Rails.cache.write(_rate_limit_hour_key, count + 1, expires_in: 1.hour)
    end
  end
end
