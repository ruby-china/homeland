require 'digest/md5'
class Reply < ActiveRecord::Base
  include BaseModel
  include SoftDelete
  include MarkdownBody
  include Likeable
  include Mentionable

  UPVOTES = %w(+1 :+1: :thumbsup: :plus1: 👍 👍🏻 👍🏼 👍🏽 👍🏾 👍🏿)

  belongs_to :user, counter_cache: true
  belongs_to :topic, touch: true, counter_cache: true
  has_many :notifications, class_name: 'Notification::Base', dependent: :destroy

  delegate :title, to: :topic, prefix: true, allow_nil: true
  delegate :login, to: :user, prefix: true, allow_nil: true

  scope :fields_for_list, -> { select(:topic_id, :id, :body_html, :updated_at, :created_at) }
  scope :without_body, -> { select(column_names - ['body'])}

  validates :body, presence: true
  validates :body, uniqueness: { scope: [:topic_id, :user_id], message: '不能重复提交。' }
  validate do
    ban_words = (SiteConfig.ban_words_on_reply || '').split("\n").collect(&:strip)
    if body.strip.downcase.in?(ban_words)
      errors.add(:body, '请勿回复无意义的内容，如你想收藏或赞这篇帖子，请用帖子后面的功能。')
    end
  end

  after_save :update_parent_topic
  def update_parent_topic
    topic.update_last_reply(self) if topic.present?
  end

  # 删除的时候也要更新 Topic 的 updated_at 以便清理缓存
  after_destroy :update_parent_topic_updated_at
  def update_parent_topic_updated_at
    unless topic.blank?
      topic.update_deleted_last_reply(self)
      true
    end
  end

  after_commit :async_create_reply_notify, on: :create
  def async_create_reply_notify
    NotifyReplyJob.perform_later(id)
  end

  after_commit :check_vote_chars_for_like_topic, on: :create
  def check_vote_chars_for_like_topic
    return unless self.upvote?
    user.like(topic)
  end

  def self.notify_reply_created(reply_id)
    reply = Reply.find_by_id(reply_id)
    return if reply.blank?
    topic = Topic.find_by_id(reply.topic_id)
    return if topic.blank?

    notified_user_ids = reply.mentioned_user_ids

    Notification::TopicReply.transaction do
      # 给发帖人发回帖通知
      if reply.user_id != topic.user_id && !notified_user_ids.include?(topic.user_id)
        Notification::TopicReply.create user_id: topic.user_id, reply_id: reply.id
        notified_user_ids << topic.user_id
      end

      follower_ids = topic.follower_ids + (reply.user.try(:follower_ids) || [])
      follower_ids.uniq!

      # 给关注者发通知

      follower_ids.each do |uid|
        # 排除同一个回复过程中已经提醒过的人
        next if notified_user_ids.include?(uid)
        # 排除回帖人
        next if uid == reply.user_id
        logger.debug "Post Notification to: #{uid}"
        Notification::TopicReply.create user_id: uid, reply_id: reply.id
      end
    end

    true
  end

  # 是否热门
  def popular?
    likes_count >= 5
  end

  def upvote?
    body.strip.start_with?(*UPVOTES)
  end

  def destroy
    super
    notifications.delete_all
    delete_notifiaction_mentions
  end
end
