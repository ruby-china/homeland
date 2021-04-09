# frozen_string_literal: true

class Profile < ApplicationRecord
  belongs_to :user

  CONTACT_FIELDS = %i[alipay paypal qq weibo wechat douban dingding aliwangwang
    facebook instagram dribbble battle_tag psn_id steam_id]

  # store :contacts, coder: JSON
  # store :rewards, coder: JSON
  # store_accessor :contacts, *CONTACT_FIELDS
  store_accessor :preferences, :theme

  validates :theme, inclusion: %w[auto light dark], allow_nil: true

  CONTACT_FIELD_PREFIXS = {
    douban: "https://www.douban.com/people/",
    weibo: "https://weibo.com/",
    facebook: "https://facebook.com/",
    instagram: "https://instagram.com/",
    dribbble: "https://dribbble.com/",
    battle_tag: "#"
  }

  def self.contact_field_label(field)
    I18n.t("activerecord.attributes.profile.contacts.#{field}")
  end

  def self.reward_field_label(field)
    I18n.t("activerecord.attributes.profile.contacts.#{field}")
  end

  def self.contact_field_prefix(field)
    CONTACT_FIELD_PREFIXS[field.to_sym]
  end

  def self.has_field?(field)
    CONTACT_FIELDS.include?(field.to_s.to_sym)
  end
end
