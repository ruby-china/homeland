# frozen_string_literal: true

require "digest/md5"
class Reply < ApplicationRecord
  include SoftDelete, MarkdownBody, Mentionable, MentionTopic, UserAvatarDelegate
  include Reply::Notify, Reply::Voteable

  belongs_to :real_user, class_name: "User", required: false
  belongs_to :user, counter_cache: true
  belongs_to :topic, touch: true
  belongs_to :target, polymorphic: true, optional: true
  belongs_to :reply_to, class_name: "Reply", optional: true

  delegate :title, to: :topic, prefix: true, allow_nil: true
  delegate :login, to: :user, prefix: true, allow_nil: true

  scope :without_system, -> { where(action: nil) }
  scope :fields_for_list, -> { select(:topic_id, :id, :body, :updated_at, :created_at) }

  # 最佳回复
  scope :suggest,            -> { where("suggested_at IS NOT NULL").order(suggested_at: :desc) }
  scope :no_suggest,         -> { where("suggested_at IS NULL") }
  scope :without_suggest,    -> { where(suggested_at: nil) }

  validates :body, presence: true, unless: -> { system_event? }
  validates :body, uniqueness: { scope: %i[topic_id user_id], message: "不能重复提交。" }, unless: -> { system_event? }
  validate do
    ban_words = Setting.ban_words_on_reply.collect(&:strip)
    if body && body.strip.downcase.in?(ban_words)
      errors.add(:body, "请勿回复无意义的内容，如你想收藏或赞这篇帖子，请用帖子后面的功能。")
    end

    if topic&.closed?
      errors.add(:topic, "已关闭，不再接受回帖或修改回帖。") unless system_event?
    end

    if reply_to_id
      self.reply_to_id = nil if reply_to&.topic_id != self.topic_id
    end
  end

  after_commit :update_parent_topic, on: :create, unless: -> { system_event? }
  def update_parent_topic
    topic.update_last_reply(self) if topic.present?
  end

  # 删除的时候也要更新 Topic 的 updated_at 以便清理缓存
  after_destroy :update_parent_topic_updated_at
  def update_parent_topic_updated_at
    unless topic.blank?
      topic.update_deleted_last_reply(self)
      # FIXME: 本应该 belongs_to :topic, touch: true 来实现的，但貌似有个 Bug 哪里没起作用
      topic.touch
    end
  end

  # 是否热门
  def popular?
    likes_count >= 5
  end

  def destroy
    super
    Notification.where(notify_type: "topic_reply", target: self).delete_all
    delete_notification_mentions
  end

  # 是否是系统事件
  def system_event?
    action.present?
  end

  def suggested?
    self.suggested_at != nil
  end

  def update_suggested_at(time)
    self.update_attribute(:suggested_at, time)
  end

  def self.create_system_event!(opts = {})
    opts[:body] ||= ""
    opts[:user] ||= Current.user
    return false if opts[:action].blank?
    return false if opts[:user].blank?
    self.create!(opts)
  end
end
