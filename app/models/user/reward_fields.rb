# frozen_string_literal: true

class User
  # 允许用户配置 Alipay|Weichat 的打赏二维码
  module RewardFields
    extend ActiveSupport::Concern

    REWARD_FIELDS = %i[alipay wechat]

    included do
      delegate :rewards, to: :profile, allow_nil: true
    end

    def reward_enabled?
      REWARD_FIELDS.each do |key|
        return true if reward_field(key).present?
      end
      false
    end

    def reward_field(field)
      return nil if self.rewards.blank?
      rewards[field.to_sym]
    end

    def update_reward_fields(field_values)
      val = self.rewards || {}
      field_values.each do |key, value|
        next unless REWARD_FIELDS.include?(key.to_sym)
        val[key.to_sym] = value
      end

      self.create_profile if self.profile.blank?
      self.profile.update(rewards: val)
    end
  end
end
