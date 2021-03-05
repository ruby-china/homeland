# frozen_string_literal: true

require "digest/md5"

class Reply < ApplicationRecord
  include UserAvatarDelegate
  include MentionTopic
  include Mentionable
  include MarkdownBody
  include SoftDelete
  include Reply::Voteable
  include Reply::Notify

  belongs_to :user, counter_cache: true
  belongs_to :topic, touch: true
  belongs_to :target, polymorphic: true, optional: true
  belongs_to :reply_to, class_name: "Reply", optional: true

  delegate :title, to: :topic, prefix: true, allow_nil: true
  delegate :login, to: :user, prefix: true, allow_nil: true

  scope :without_system, -> { where(action: nil) }
  scope :fields_for_list, -> { select(:topic_id, :id, :body, :updated_at, :created_at) }

  validates :body, presence: true, unless: -> { system_event? }
  validates :body, uniqueness: {scope: %i[topic_id user_id], message: I18n.t("replies.duplicate_error")}, unless: -> { system_event? }
  validate do
    ban_words = Setting.ban_words_on_reply.collect(&:strip)
    if !system_event? && body&.strip&.downcase&.in?(ban_words)
      errors.add(:body, I18n.t("replies.nopoint_limit"))
    end

    if topic&.closed?
      errors.add(:topic, I18n.t("replies.close_limit")) unless system_event?
    end

    if reply_to_id
      self.reply_to_id = nil if reply_to&.topic_id != topic_id
    end
  end

  after_commit :update_parent_topic, on: :create, unless: -> { system_event? }
  def update_parent_topic
    topic.update_last_reply(self) if topic.present?
  end

  # Touch updated_at for expire Topic cache
  after_destroy :update_parent_topic_updated_at
  def update_parent_topic_updated_at
    unless topic.blank?
      topic.update_deleted_last_reply(self)
      topic.touch
    end
  end

  def popular?
    likes_count >= 5
  end

  def destroy
    super
    Notification.where(notify_type: "topic_reply", target: self).delete_all
    delete_notification_mentions
  end

  def system_event?
    action.present?
  end

  def self.create_system_event!(opts = {})
    opts[:body] ||= ""
    opts[:user] ||= Current.user
    return false if opts[:action].blank?
    return false if opts[:user].blank?
    create!(opts)
  end
end
