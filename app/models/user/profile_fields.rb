# frozen_string_literal: true

class User
  # 用户个性资料，支持任意扩展，基于 rails-settings-cached 的特性
  module ProfileFields
    extend ActiveSupport::Concern

    included do
      include RailsSettings::Extend

      PROFILE_FIELDS = %i[alipay paypal qq weibo wechat douban dingding aliwangwang
                          facebook instagram dribbble battle_tag psn_id steam_id]

      PROFILE_FIELD_PREFIXS = {
        douban: "https://www.douban.com/people/",
        weibo: "https://weibo.com/",
        facebook: "https://facebook.com/",
        instagram: "https://instagram.com/",
        dribbble: "https://dribbble.com/",
        battle_tag: "#"
      }

      before_save :store_location
    end

    def profile_fields
      return @profile_fields if defined? @profile_fields
      @profile_fields = self.settings.profile_fields || {}
      unless @profile_fields.is_a?(Hash)
        @profile_fields = {}
      end
      @profile_fields
    end

    def profile_field(field)
      return nil unless PROFILE_FIELDS.include?(field.to_sym)
      profile_fields[field.to_sym]
    end

    def full_profile_field(field)
      v = profile_field(field)
      prefix = User.profile_field_prefix(field)
      return v if prefix.blank?
      [prefix, v].join("")
    end

    def update_profile_fields(field_values)
      field_values.each do |key, value|
        next unless PROFILE_FIELDS.include?(key.to_sym)
        profile_fields[key.to_sym] = value
      end
      self.settings.profile_fields = profile_fields
    end

    module ClassMethods
      def profile_field_prefix(field)
        PROFILE_FIELD_PREFIXS[field.to_sym]
      end

      def profile_field_label(field)
        I18n.t("activerecord.attributes.user.profile_fields.#{field}")
      end
    end

    private
      # 在用户设置 user.location 保存的时候，自动创建 Location 数据，并更新统计
      def store_location
        return if !self.location_changed?

        if location.blank?
          self.location_id = nil
          return
        end

        old_location = Location.location_find_by_name(self.location_was)
        old_location&.decrement!(:users_count)

        location = Location.location_find_or_create_by_name(self.location)
        if !location.new_record?
          location.increment!(:users_count)
          self.location_id = location.id
        end
      end
  end
end
