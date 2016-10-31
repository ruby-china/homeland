require 'digest/md5'
class Reply < ApplicationRecord
  include SoftDelete
  include MarkdownBody
  include Likeable
  include Mentionable
  include MentionTopic

  UPVOTES = %w(+1 :+1: :thumbsup: :plus1: 👍 👍🏻 👍🏼 👍🏽 👍🏾 👍🏿)

  belongs_to :user, counter_cache: true
  belongs_to :topic, touch: true
  belongs_to :target, polymorphic: true

  delegate :title, to: :topic, prefix: true, allow_nil: true
  delegate :login, to: :user, prefix: true, allow_nil: true

  scope :without_system, -> { where(action: nil) }
  scope :fields_for_list, -> { select(:topic_id, :id, :body_html, :updated_at, :created_at) }
  scope :without_body, -> { select(column_names - ['body']) }

  validates :body, presence: true, unless: -> { system_event? }
  validates :body, uniqueness: { scope: [:topic_id, :user_id], message: '不能重复提交。' }, unless: -> { system_event? }
  validate do
    ban_words = (Setting.ban_words_on_reply || '').split("\n").collect(&:strip)
    if body.strip.downcase.in?(ban_words)
      errors.add(:body, '请勿回复无意义的内容，如你想收藏或赞这篇帖子，请用帖子后面的功能。')
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

  after_commit :async_create_reply_notify, on: :create, unless: -> { system_event? }
  def async_create_reply_notify
    NotifyReplyJob.perform_later(id)
  end

  after_commit :check_vote_chars_for_like_topic, on: :create, unless: -> { system_event? }
  def check_vote_chars_for_like_topic
    return unless self.upvote?
    user.like(topic)
  end

  def self.notify_reply_created(reply_id)
    reply = Reply.find_by_id(reply_id)
    return if reply.blank?
    return if reply.system_event?
    topic = Topic.find_by_id(reply.topic_id)
    return if topic.blank?

    notified_user_ids = reply.mentioned_user_ids

    # 给发帖人发回帖通知
    if reply.user_id != topic.user_id && !notified_user_ids.include?(topic.user_id)
      Notification.create notify_type: 'topic_reply',
                          actor_id: reply.user_id,
                          user_id: topic.user_id,
                          target: reply,
                          second_target: topic
      notified_user_ids << topic.user_id
    end

    follower_ids = topic.follower_ids + (reply.user.try(:follower_ids) || [])
    follower_ids.uniq!

    # 给关注者发通知
    default_note = {
      notify_type: 'topic_reply',
      target_type: 'Reply', target_id: reply.id,
      second_target_type: 'Topic', second_target_id: topic.id,
      actor_id: reply.user_id
    }
    Notification.bulk_insert(set_size: 100) do |worker|
      follower_ids.each do |uid|
        # 排除同一个回复过程中已经提醒过的人
        next if notified_user_ids.include?(uid)
        # 排除回帖人
        next if uid == reply.user_id
        logger.debug "Post Notification to: #{uid}"
        note = default_note.merge(user_id: uid)
        worker.add(note)
      end
    end

    # Touch realtime_push_to_client
    follower_ids.each do |uid|
      next if notified_user_ids.include?(uid)
      n = Notification.where(user_id: uid).last
      n.realtime_push_to_client
    end
    self.broadcast_to_client(reply)

    true
  end

  def self.broadcast_to_client(reply)
    ActionCable.server.broadcast("topics/#{reply.topic_id}/replies", id: reply.id, user_id: reply.user_id, action: :create)
  end

  # 是否热门
  def popular?
    likes_count >= 5
  end

  def upvote?
    (body || '').strip.start_with?(*UPVOTES)
  end

  def destroy
    super
    Notification.where(notify_type: 'topic_reply', target: self).delete_all
    delete_notifiaction_mentions
  end

  # 是否是系统事件
  def system_event?
    action.present?
  end

  def self.create_system_event(opts = {})
    opts[:body] = ''
    opts[:user] ||= User.current
    return false if opts[:action].blank?
    return false if opts[:user].blank?
    self.create(opts)
  end
end
