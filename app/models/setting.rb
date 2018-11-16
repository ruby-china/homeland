# frozen_string_literal: true

# RailsSettings Model
class Setting < RailsSettings::Base
  source Rails.root.join("config/config.yml")

  class << self
    def field(key, default: nil, type: :string, separator: nil)
      self.class.define_method(key) do
        val = self[key]
        default = default.call if default.is_a?(Proc)
        return default if val.nil?
        val
      end

      if type == :boolean
        self.class.define_method("#{key}?") do
          val = self.send(key.to_sym)
          val == "true" || val == "1"
        end
      elsif type == :array
        self.class.define_method("#{key.to_s.singularize}_list") do
          val = self.send(key.to_sym) || ""
          separator = SEPARATOR_REGEXP if separator.nil?
          val.split(separator).reject { |str| str.empty? }
        end
      end
    end
  end

  # List setting value separator chars
  SEPARATOR_REGEXP = /[\s,]/

  # keys that allow update in admin
  KEYS_IN_ADMIN = %w[
    app_name
    navbar_brand_html
    default_locale
    auto_locale
    admin_emails
    custom_head_html
    navbar_html
    footer_html
    index_html
    wiki_index_html
    wiki_sidebar_html
    site_index_html
    topic_index_sidebar_html
    after_topic_html
    before_topic_html
    node_ids_hide_in_topics_index
    reject_newbie_reply_in_the_evening
    newbie_limit_time
    ban_words_on_reply
    newbie_notices
    tips
    apns_pem
    blacklist_ips
    ban_reason_html
    ban_reasons
    topic_create_limit_interval
    topic_create_hour_limit_count
    allow_change_login
  ]

  field :app_name, default: "Homeland"
  field :navbar_brand_html, default: -> { %(<a href="/" class="navbar-brand"><b>#{self.app_name}</b></a>) }
  field :default_locale, default: "zh-CN"
  field :auto_locale, default: "false", type: :boolean
  field :reject_newbie_reply_in_the_evening, default: "false", type: :boolean
  field :topic_create_rate_limit, default: "false", type: :boolean
  field :admin_emails, default: "admin@admin.com", type: :array
  field :ban_reasons, default: "标题或正文描述不清楚", type: :array, separator: "\n"
  field :ban_reason_html, default: "此贴因内容原因不符合要求，被管理员屏蔽，请根据管理员给出的原因进行调整"
  field :modules, default: "all", type: :array
  field :profile_fields, default: "all", type: :array
  field :allow_change_login, default: false, type: :boolean

  class << self
    def protocol
      self.https == true ? "https" : "http"
    end

    def base_url
      [self.protocol, self.domain].join("://")
    end

    def has_admin?(email)
      return false if self.admin_email_list.blank?
      self.admin_email_list.include?(email)
    end

    def has_module?(name)
      return true if self.modules.blank? || self.modules == "all"
      self.module_list.include?(name.to_s)
    end

    def has_profile_field?(name)
      return true if self.profile_fields.blank? || self.profile_fields == "all"
      self.profile_field_list.include?(name.to_s)
    end

    def sso_enabled?
      return false if self.sso_provider_enabled?
      self.sso["enable"] == true
    end

    def sso_provider_enabled?
      self.sso["enable_provider"] == true
    end
  end
end
