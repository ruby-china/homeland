# RailsSettings Model
class Setting < RailsSettings::Base
  source Rails.root.join('config/config.yml')

  # List setting value separator chars
  SEPARATOR_REGEXP = /[\s,]/

  # keys that allow update in admin
  KEYS_IN_ADMIN = %w(
    custom_head_html
    navbar_html
    navbar_brand_html
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
    ban_words_on_reply
    newbie_notices
    tips
    apns_pem
    blacklist_ips
    admin_emails
  )

  class << self
    def protocol
      self.https == true ? 'https' : 'http'
    end

    def host
      [self.protocol, self.domain].join("://")
    end

    def has_admin?(email)
      self.admin_emails.split(SEPARATOR_REGEXP).include?(email)
    end

    # topic,home,wiki,site,note,team,github
    def has_module?(name)
      return true if self.modules.blank? || self.modules == 'all'
      self.modules.split(SEPARATOR_REGEXP).include?(name.to_s)
    end
  end
end
