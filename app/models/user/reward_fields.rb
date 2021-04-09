# frozen_string_literal: true

class User
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
      return nil if rewards.blank?
      rewards[field.to_s]
    end

    def update_reward_fields(field_values)
      val = rewards || {}
      field_values.each do |key, value|
        next unless REWARD_FIELDS.include?(key.to_sym)
        val[key.to_s] = value
      end

      create_profile if profile.blank?
      profile.update(rewards: val)
    end
  end
end
