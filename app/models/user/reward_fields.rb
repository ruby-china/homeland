class User
  module RewardFields
    extend ActiveSupport::Concern

    included do
      include RailsSettings::Extend

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

    def reward_fields
      return @reward_fields if defined? @reward_fields
      @reward_fields = self.settings.reward_fields || {}
      unless @reward_fields.is_a?(Hash)
        @reward_fields = {}
      end
      @reward_fields
    end

    def update_reward_fields(field_values)
      field_values.each do |key, value|
        next unless REWARD_FIELDS.include?(key.to_sym)
        reward_fields[key.to_sym] = value
      end
      self.settings.reward_fields = reward_fields
    end

    module ClassMethods
      def reward_field_label(field)
        I18n.t("activerecord.attributes.user.profile_fields.#{field}")
      end
    end
  end
end
