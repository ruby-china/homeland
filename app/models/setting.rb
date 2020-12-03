# frozen_string_literal: true

# RailsSettings Model
class Setting < RailsSettings::Base
  concerning :Legacy do
    LEGECY_ENVS = {
      github_token: "github_api_key",
      github_secret: "github_api_secret",
    }

    included do
    end

    class_methods do
      def legecy_env_instead(key)
        LEGECY_ENVS[key]
      end

      def legecy_envs
        keys = []
        LEGECY_ENVS.each_key do |key|
          keys << key if ENV[key.to_s].present?
        end
        keys
      end
    end
  end

  SYSTEM_KEYS = %w[require_restart domain https asset_host]

  # keys that allow update without restart
  HOT_UPDATE_KEYS = %w[
    default_locale
    auto_locale
    timezone
    admin_emails
    navbar_brand_html
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
    ban_words_in_body
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
    twitter_id
    share_allow_sites
    editor_languages
    sorted_plugins
    profile_fields
  ]

  # = System
  field :require_restart, default: false, type: :boolean
  field :domain, default: (ENV["domain"] || "localhost"), readonly: true
  field :https, type: :boolean, default: (ENV["https"] || "true"), readonly: true
  field :asset_host, default: (ENV["asset_host"] || nil), readonly: true

  # = Basic
  field :app_name, default: (ENV["app_name"] || "Homeland")
  field :timezone, default: "UTC"
  # Module [topic,home,team,github,editor.code]
  field :modules, default: (ENV["modules"] || "all"), type: :array
  # Plugin sort
  field :sorted_plugins, default: [], type: :array, separator: /[\s,]+/
  # User profile module default: all [company,twitter,website,tagline,location,alipay,paypal,qq,weibo,wechat,douban,dingding,aliwangwang,facebook,instagram,dribbble,battle_tag,psn_id,steam_id]
  field :profile_fields, default: (ENV["profile_fields"] || "all"), type: :array

  # = Rack Attach
  field :rack_attack, type: :hash, default: {
    limit: ENV["rack_attack.limit"] || 0,
    period: ENV["rack_attack.period"] || 3.minutes,
  }

  # = Uploader
  # can be  upyun/aliyun
  field :upload_provider, default: (ENV["upload_provider"] || "file"), readonly: true
  # access_id or upyun username
  field :upload_access_id, default: ENV["upload_access_id"], readonly: true
  # access_secret or upyun password
  field :upload_access_secret, default: ENV["upload_access_secret"], readonly: true
  field :upload_bucket, default: ENV["upload_bucket"], readonly: true
  field :upload_url, default: ENV["upload_url"], readonly: true
  field :upload_aliyun_internal, type: :boolean, default: (ENV["upload_aliyun_internal"] || "false"), readonly: true
  field :upload_aliyun_region, default: (ENV["upload_aliyun_region"] || ENV["upload_aliyun_area"]), readonly: true

  # = Mailer
  field :mailer_provider, default: (ENV["mailer_provider"] || "smtp"), readonly: true
  field :mailer_sender, default: (ENV["mailer_sender"] || "no-reply@localhost"), readonly: true
  field :mailer_options, type: :hash, readonly: true, default: {
    api_key: (ENV["mailer_options_api_key"] || ENV["mailer_options.api_key"]),
    address: (ENV["mailer_options_address"] || ENV["mailer_options.address"]),
    port: (ENV["mailer_options_port"] || ENV["mailer_options.port"]),
    domain: (ENV["mailer_options_domain"] || ENV["mailer_options.domain"]),
    user_name: (ENV["mailer_options_user_name"] || ENV["mailer_options.user_name"]),
    password: (ENV["mailer_options_password"] || ENV["mailer_options.password"]),
    authentication: (ENV["mailer_options_authentication"] || ENV["mailer_options.authentication"] || "login"),
    enable_starttls_auto: (ENV["mailer_options_enable_starttls_auto"] || ENV["mailer_options.enable_starttls_auto"])
  }

  # = SSO
  field :sso, type: :hash, readonly: true, default: {
    enable: (ENV["sso_enable"] || ENV["sso.enable"] || false),
    enable_provider: (ENV["sso_enable_provider"] || ENV["sso_enable.provider"] || false),
    url: (ENV["sso_url"] || ENV["sso.url"]),
    secret: (ENV["sso_secret"] || ENV["sso.secret"]),
  }

  # = Omniauth API Keys
  field :github_api_key, default: (ENV["github_api_key"] || ENV["github_token"])
  field :github_api_secret, default: (ENV["github_api_secret"] || ENV["github_secret"])
  field :twitter_api_key, default: ENV["twitter_api_key"]
  field :twitter_api_secret, default: ENV["twitter_api_secret"]
  field :wechat_api_key, default: ENV["wechat_api_key"]
  field :wechat_api_secret, default: ENV["wechat_api_secret"]

  # = Other Site Configs
  field :admin_emails, type: :array, default: (ENV["admin_emails"] || "admin@admin.com"), separator: /[\s,]+/

  field :newbie_limit_time, type: :integer, default: 0
  field :topic_create_limit_interval, type: :integer, default: 0
  field :topic_create_hour_limit_count, type: :integer, default: 0
  field :sign_up_daily_limit, type: :integer, default: 0

  field :reject_newbie_reply_in_the_evening, default: "false", type: :boolean
  field :allow_change_login, type: :boolean, default: (ENV["allow_change_login"] || false)
  field :topic_create_rate_limit, default: "false", type: :boolean
  field :node_ids_hide_in_topics_index, type: :array, default: []

  field :apns_pem, default: ""
  field :blacklist_ips, default: [], type: :array

  field :twitter_id
  field :share_allow_sites, default: %w[twitter weibo facebook wechat], type: :array, separator: /[\s]+/

  # = UI custom html
  field :navbar_brand_html, default: -> { %(<a href="/" class="navbar-brand"><b>#{self.app_name}</b></a>) }
  field :default_locale, default: "zh-CN"
  field :auto_locale, default: "false", type: :boolean
  field :custom_head_html, default: ""
  field :navbar_html, default: ""
  field :footer_html, default: ""
  field :index_html, default: ""
  field :wiki_index_html, default: ""
  field :wiki_sidebar_html, default: ""
  field :site_index_html, default: ""
  field :topic_index_sidebar_html, default: ""
  field :before_topic_html, default: ""
  field :after_topic_html, default: ""
  field :topic_index_sidebar_html, default: ""
  field :ban_reasons, default: "标题或正文描述不清楚", type: :array, separator: /[\n]+/
  field :ban_reason_html, default: "此贴因内容原因不符合要求，被管理员屏蔽，请根据管理员给出的原因进行调整"
  field :ban_words_on_reply, default: [], type: :array, separator: /[\n]+/
  field :ban_words_in_body, default: [], type: :array, separator: /[\n]+/
  field :newbie_notices, default: ""
  field :tips, default: [], type: :array, separator: /[\n]+/
  field :editor_languages, default: %w[rb go js py java rs php css html yml json xml], type: :array, separator: /[\s,]+/

  # = ReCaptcha
  field :use_recaptcha, default: false, type: :boolean
  # default key for development env
  field :recaptcha_key, default: "6Lcalg8TAAAAAFhLrcbC4QmxNuseboteXxP3wLxI"
  field :recaptcha_secret, default: "6Lcalg8TAAAAAN-nZr547ORtmtpw78mTLWtVWFW2"
  field :google_analytics_key, default: ""

  # = Emoji
  field :emoji_enable, type: :boolean, default: (ENV["emoji_enable"] || true)

  class << self
    def protocol
      self.https? ? "https" : "http"
    end

    def base_url
      return "http://localhost:3000" if Rails.env.development?
      [self.protocol, self.domain].join("://")
    end

    def has_module?(name)
      return true if self.modules.blank? || self.modules.include?("all")
      self.modules.map { |str| str.strip }.include?(name.to_s)
    end

    def has_omniauth?(provider)
      case provider.to_s
      when "github"
        self.github_api_key.present?
      when "twitter"
        self.twitter_api_key.present?
      when "wechat"
        self.wechat_api_key.present?
      else
        false
      end
    end

    def has_profile_field?(name)
      return true if self.profile_fields.blank? || self.profile_fields.include?("all")
      self.profile_fields.map { |str| str.strip }.include?(name.to_s)
    end

    def sso_enabled?
      return false if self.sso_provider_enabled?
      self.sso[:enable] == true
    end

    def sso_provider_enabled?
      self.sso[:enable_provider] == true
    end

    def rails_initialized?
      true
    end

    # https://regex101.com/r/m1UOqT/1
    def cable_allowed_request_origin
      /http(s)?:\/\/#{Setting.domain}(:[\d]+)?/
    end

    def can_emoji?
      self.emoji_enable? == true
    end
  end

  def require_restart?
    !HOT_UPDATE_KEYS.include?(self.var)
  end

  def type
    @option ||= self.class.get_field(self.var)
    @option[:type]
  end
end
