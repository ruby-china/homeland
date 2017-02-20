class User
  module ProfileFields
    extend ActiveSupport::Concern

    included do
      include RailsSettings::Extend

      PROFILE_FILEDS = %i(alipay paypal qq weibo wechat douban dingding aliwangwang
                          facebook instagram dribbble battle_tag psn_id steam_id)

      PROFILE_FIELD_PREFIXS = {
        douban: 'https://www.douban.com/people/',
        weibo: 'https://weibo.com/',
        facebook: 'https://facebook.com/',
        instagram: 'https://instagram.com/',
        dribbble: 'https://dribbble.com/',
        battle_tag: '#'
      }
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
      return nil unless PROFILE_FILEDS.include?(field.to_sym)
      profile_fields[field.to_sym]
    end

    def full_profile_field(field)
      v = profile_field(field)
      prefix = User.profile_field_prefix(field)
      return v if prefix.blank?
      [prefix, v].join('')
    end

    def update_profile_fields(field_values)
      field_values.each do |key, value|
        next unless PROFILE_FILEDS.include?(key.to_sym)
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
  end
end
