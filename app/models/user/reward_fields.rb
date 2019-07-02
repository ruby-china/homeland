# frozen_string_literal: true

class User
  # 允许用户配置 Alipay|Weichat 的打赏二维码
  module RewardFields
    extend ActiveSupport::Concern

    included do
      include ScopedSetting

      scoped_field :reward_fields, default: {}

      REWARD_FIELDS = %i[alipay wechat]
    end

    def reward_enabled?
      REWARD_FIELDS.each do |key|
        return true if reward_field(key).present?
      end
      false
    end

    def reward_field(field)
      return nil unless REWARD_FIELDS.include?(field.to_sym)
      reward_fields[field.to_sym]
    end

    def update_reward_fields(field_values)
      val = self.reward_fields
      field_values.each do |key, value|
        next unless REWARD_FIELDS.include?(key.to_sym)
        val[key.to_sym] = value
      end
      self.reward_fields = val
    end

    module ClassMethods
      def reward_field_label(field)
        I18n.t("activerecord.attributes.user.profile_fields.#{field}")
      end
    end
  end
end
