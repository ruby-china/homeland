# frozen_string_literal: true

# RailsSettings Model
class Setting < RailsSettings::Base
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
    sign_up_daily_limit
    use_recaptcha
    recaptcha_key
    recaptcha_secret
  ]

  # = Basic
  field :app_name, default: (ENV["app_name"] || "Homeland"), readonly: true
  # Plugin module, [topic,home,wiki,site,note,team,github,editor.code,press,jobs]
  field :modules, default: (ENV["modules"] || "all"), type: :array, readonly: true
  # User profile module default: all [company,twitter,website,tagline,location,alipay,paypal,qq,weibo,wechat,douban,dingding,aliwangwang,facebook,instagram,dribbble,battle_tag,psn_id,steam_id]
  field :profile_fields, default: (ENV["profile_fields"] || "all"), type: :array, readonly: true
  field :domain, default: (ENV["domain"] || "localhost"), readonly: true
  field :https, type: :boolean, default: (ENV["https"] || "true"), readonly: true
  field :asset_host, default: ENV['asset_host'], readonly: true

  # = Rack Attach
  field :rack_attack, type: :hash, readonly: true, default: {
    limit: ENV['rack_attack_limit'] || ENV['rack_attack.limit'] || "false",
    period: ENV['rack_attack_period'] || ENV['rack_attack.period'],
  }

  # = Uploader
  # can be  upyun/aliyun
  field :upload_provider, default: (ENV['upload_provider'] || 'file'), readonly: true
  # access_id or upyun username
  field :upload_access_id, default: ENV['upload_access_id'], readonly: true
  # access_secret or upyun password
  field :upload_access_secret, default: ENV['upload_access_secret'], readonly: true
  field :upload_bucket, default: ENV['upload_bucket'], readonly: true
  field :upload_url, default: ENV['upload_url'], readonly: true
  field :upload_aliyun_internal, type: :boolean, default: (ENV['upload_aliyun_internal'] || "false"), readonly: true
  field :upload_aliyun_area, default: ENV['upload_aliyun_area'], readonly: true

  # = Mailer
  field :mailer_provider, default: (ENV['mailer_provider'] || 'smtp'), readonly: true
  field :mailer_sender, default: (ENV['mailer_sender'] || 'no-reply@localhost'), readonly: true
  field :mailer_options, type: :hash, readonly: true, default: {
    api_key: (ENV['mailer_options_api_key'] || ENV['mailer_options.api_key']),
    address: (ENV['mailer_options_address'] || ENV['mailer_options.address']),
    port: (ENV['mailer_options_port'] || ENV['mailer_options.port']),
    domain: (ENV['mailer_options_domain'] || ENV['mailer_options.domain']),
    user_name: (ENV['mailer_options_user_name'] || ENV['mailer_options.user_name']),
    password: (ENV['mailer_options_password'] || ENV['mailer_options.password']),
    authentication: (ENV['mailer_options_authentication'] || ENV['mailer_options.authentication'] || "login"),
    enable_starttls_auto: (ENV['mailer_options_enable_starttls_auto'] || ENV['mailer_options.enable_starttls_auto'])
  }

  # = SSO
  field :sso, type: :hash, readonly: true, default: {
    enable: (ENV['sso_enable'] || ENV['sso.enable'] || false),
    enable_provider: (ENV['sso_enable_provider'] || ENV['sso_enable.provider'] || false),
    url: (ENV['sso_url'] || ENV['sso.url']),
    secret: (ENV['sso_secret'] || ENV['sso.secret']),
  }

  # = API Keys
  field :github_token, default: ENV['github_token'], readonly: true
  field :github_secret, default: ENV['github_secret'], readonly: true

  # = Other Site Configs
  field :admin_emails, type: :array, default: (ENV['admin_emails'] || "admin@admin.com")

  field :newbie_limit_time, type: :integer, default: 0
  field :topic_create_limit_interval, type: :integer, default: 0
  field :topic_create_hour_limit_count, type: :integer, default: 0
  field :sign_up_daily_limit, type: :integer, default: 0

  field :allow_change_login, type: :boolean, default: (ENV['allow_change_login'] || false)

  field :navbar_brand_html, default: -> { %(<a href="/" class="navbar-brand"><b>#{self.app_name}</b></a>) }
  field :default_locale, default: "zh-CN"
  field :auto_locale, default: "false", type: :boolean
  field :reject_newbie_reply_in_the_evening, default: "false", type: :boolean
  field :topic_create_rate_limit, default: "false", type: :boolean
  field :ban_reasons, default: "标题或正文描述不清楚", type: :array, separator: "\n"
  field :ban_reason_html, default: "此贴因内容原因不符合要求，被管理员屏蔽，请根据管理员给出的原因进行调整"

  # = ReCaptcha
  field :use_recaptcha, default: false, type: :boolean
  # default key for development env
  field :recaptcha_key, default: "6Lcalg8TAAAAAFhLrcbC4QmxNuseboteXxP3wLxI"
  field :recaptcha_secret, default: "6Lcalg8TAAAAAN-nZr547ORtmtpw78mTLWtVWFW2"

  class << self
    def protocol
      self.https? ? "https" : "http"
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
      self.modules.include?(name.to_s)
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
