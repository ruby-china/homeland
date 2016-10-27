# RailsSettings Model
class Setting < RailsSettings::Base
  source Rails.root.join('config/config.yml')

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
    new_topic_dropdown_node_ids
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

    def has_module?(name)
      return true if self.modules.blank? || self.modules == 'all'
      self.modules.include?(name.to_s)
    end
  end
end
