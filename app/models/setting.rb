# RailsSettings Model
class Setting < RailsSettings::Base
  LEGECY_ENVS = {
    github_token: "github_api_key",
    github_secret: "github_api_secret"
  }

  concerning :Legacy do
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
    captcha_enable
    use_recaptcha
    recaptcha_key
    recaptcha_secret
    twitter_id
    share_allow_sites
    editor_languages
    sorted_plugins
    profile_fields
    google_analytics_key
    twitter_api_key
    twitter_api_secret
    github_api_key
    github_api_secret
    wechat_api_key
    wechat_api_secret
    imageproxy_url
    mailer_provider
    mailer_sender
    mailer_options
    mainfest
  ]

  scope :basic do
    field :app_name, default: (ENV["app_name"] || "Homeland"), validates: { presence: true }
    field :timezone, default: "UTC"
    # Module [topic,team,github,editor.code]
    field :modules, default: (ENV["modules"] || "all"), type: :array
    # Plugin sort
    field :sorted_plugins, default: [], type: :array, separator: /[\s,]+/
    # User profile module default: all [company,twitter,website,tagline,location,alipay,paypal,qq,weibo,wechat,douban,dingding,aliwangwang,facebook,instagram,dribbble,battle_tag,psn_id,steam_id]
    field :profile_fields, default: (ENV["profile_fields"] || "all"), type: :array
    field :admin_emails, type: :array, default: (ENV["admin_emails"] || "admin@admin.com"), separator: /[\s,]+/
    field :twitter_id
    field :share_allow_sites, default: %w[twitter weibo facebook wechat], type: :array, separator: /\s+/
    field :editor_languages, default: %w[rb go js py java rs php css html yml json xml], type: :array, separator: /[\s,]+/
    field :google_analytics_key, default: ""
    field :manifest, type: :hash, default: {
      name: "Homeland",
      short_name: "Homeland",
      description: "Open source discussion website.",
      start_url: "/",
      display: "standalone",
      background_color: "#FFFFFF",
      theme_color: "#FFFFFF",
      icons: [
        {
          src: "https://l.ruby-china.com/photo/2018/bd93b12d-98d0-47a4-9f7a-128b8a3271f7.png",
          sizes: "512x512",
          type: "image/png"
        }
      ]
    }
  end

  scope :appearance do
    field :navbar_brand_html, default: -> { %(<a href="/" class="navbar-brand"><b>#{app_name}</b></a>) }
    field :default_locale, default: "en", validates: { presence: true, inclusion: { in: %w[en zh-CN] } }
    field :auto_locale, default: "false", type: :boolean
    field :custom_head_html, default: ""
    field :navbar_html, default: ""
    field :footer_html, default: ""
    field :wiki_index_html, default: ""
    field :wiki_sidebar_html, default: ""
    field :site_index_html, default: ""
    field :topic_index_sidebar_html, default: ""
    field :before_topic_html, default: ""
    field :after_topic_html, default: ""
    field :ban_reasons, default: "标题或正文描述不清楚", type: :array, separator: /\n+/
    field :ban_reason_html, default: "此贴因内容原因不符合要求，被管理员屏蔽，请根据管理员给出的原因进行调整"
    field :ban_words_on_reply, default: [], type: :array, separator: /\n+/
    field :ban_words_in_body, default: [], type: :array, separator: /\n+/
    field :newbie_notices, default: ""
    field :tips, default: [], type: :array, separator: /\n+/
  end

  scope :uploader do
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
    field :imageproxy_url
  end

  scope :mailer do
    field :mailer_provider, default: (ENV["mailer_provider"] || "smtp")
    field :mailer_sender, default: (ENV["mailer_sender"] || "no-reply@localhost")
    field :mailer_options, type: :hash, default: {
      api_key: ENV["mailer_options_api_key"],
      address: ENV["mailer_options_address"],
      port: ENV["mailer_options_port"],
      domain: ENV["mailer_options_domain"],
      user_name: ENV["mailer_options_user_name"],
      password: ENV["mailer_options_password"],
      authentication: (ENV["mailer_options_authentication"] || "login"),
      enable_starttls_auto: ENV["mailer_options_enable_starttls_auto"]
    }
  end

  scope :auth do
    field :sso, type: :hash, readonly: true, default: {
      enable: (ENV["sso_enable"] || false),
      enable_provider: (ENV["sso_enable_provider"] || false),
      url: ENV["sso_url"],
      secret: ENV["sso_secret"]
    }

    # = Omniauth API Keys
    field :github_api_key, default: ENV["github_api_key"]
    field :github_api_secret, default: ENV["github_api_secret"]
    field :twitter_api_key, default: ENV["twitter_api_key"]
    field :twitter_api_secret, default: ENV["twitter_api_secret"]
    field :wechat_api_key, default: ENV["wechat_api_key"]
    field :wechat_api_secret, default: ENV["wechat_api_secret"]
  end

  # = Other Site Configs
  scope :limits do
    field :rack_attack, type: :hash, default: {
      limit: 0,
      period: 3.minutes
    }

    field :newbie_limit_time, type: :integer, default: 0
    field :topic_create_limit_interval, type: :integer, default: 0
    field :topic_create_hour_limit_count, type: :integer, default: 0
    field :sign_up_daily_limit, type: :integer, default: 0

    field :reject_newbie_reply_in_the_evening, default: "false", type: :boolean
    field :allow_change_login, type: :boolean, default: (ENV["allow_change_login"] || false)
    field :topic_create_rate_limit, default: "false", type: :boolean
    field :node_ids_hide_in_topics_index, type: :array, default: []
    field :blacklist_ips, default: [], type: :array
  end

  scope :captcha do
    field :captcha_enable, default: false, type: :boolean
    field :use_recaptcha, default: false, type: :boolean
    # default key for development env
    field :recaptcha_key, default: "6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI"
    field :recaptcha_secret, default: "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe"
  end

  field :require_restart, default: false, type: :boolean
  field :domain, readonly: true
  field :asset_host, default: (ENV["asset_host"] || nil), readonly: true
  field :apns_pem, default: ""

  class << self
    def protocol
      Rails.env.production? ? "https" : "http"
    end

    def safe_domain
      ENV.fetch("domain", "localhost").split(",").first.delete_prefix("*.")
    end

    def domain
      @domain ||= safe_domain
    end

    def base_url
      return "http://localhost:3000" if Rails.env.development?
      [protocol, domain].join("://")
    end

    def has_module?(name)
      return true if modules.blank? || modules.include?("all")
      modules.map { |str| str.strip }.include?(name.to_s)
    end

    def has_omniauth?(provider)
      case provider.to_s
      when "github"
        github_api_key.present?
      when "twitter"
        twitter_api_key.present?
      when "wechat"
        wechat_api_key.present?
      else
        false
      end
    end

    def omniauth_providers
      User.omniauth_providers.filter { |provider| has_omniauth?(provider) }
    end

    def has_profile_field?(name)
      return true if profile_fields.blank? || profile_fields.include?("all")
      profile_fields.map { |str| str.strip }.include?(name.to_s)
    end

    def sso_enabled?
      return false if sso_provider_enabled?
      sso[:enable] == "true"
    end

    def sso_provider_enabled?
      sso[:enable_provider] == "true"
    end

    def rails_initialized?
      true
    end

    # https://regex101.com/r/m1UOqT/1
    def cable_allowed_request_origin
      /http(s)?:\/\/#{Setting.domain}(:\d+)?/
    end

    # Host that ImageProxy will ignore
    def imageproxy_ignore_hosts
      [upload_url, asset_host, base_url].map do |url|
        URI(url).host
      rescue
        return nil
      end.compact
    end
  end

  def require_restart?
    !HOT_UPDATE_KEYS.include?(var)
  end

  def type
    @option ||= self.class.get_field(var)
    @option[:type]
  end
end
