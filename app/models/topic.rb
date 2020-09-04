# frozen_string_literal: true

class Topic < ApplicationRecord
  include SoftDelete, MarkdownBody, Mentionable, MentionTopic, Closeable, Searchable, UserAvatarDelegate
  include Topic::Actions, Topic::AutoCorrect, Topic::Search, Topic::Notify, Topic::RateLimit

  # 临时存储检测用户是否读过的结果
  attr_accessor :read_state

  belongs_to :user, inverse_of: :topics, counter_cache: true, required: false
  belongs_to :team, counter_cache: true, required: false
  belongs_to :node, counter_cache: true, required: false
  belongs_to :last_reply_user, class_name: "User", required: false
  belongs_to :last_reply, class_name: "Reply", required: false
  has_many :replies, dependent: :destroy

  validates :user_id, :title, :body, :node_id, presence: true

  validate :check_topic_ban_words, on: :create

  counter :hits, default: 0

  delegate :login, to: :user, prefix: true, allow_nil: true
  delegate :body, to: :last_reply, prefix: true, allow_nil: true

  # scopes
  scope :last_actived,       -> { order(last_active_mark: :desc) }
  scope :suggest,            -> { where("suggested_at IS NOT NULL").order(suggested_at: :desc) }
  scope :without_suggest,    -> { where(suggested_at: nil) }
  scope :high_likes,         -> { order(likes_count: :desc).order(id: :desc) }
  scope :high_replies,       -> { order(replies_count: :desc).order(id: :desc) }
  scope :last_reply,         -> { where("last_reply_id IS NOT NULL").order(last_reply_id: :desc) }
  scope :no_reply,           -> { where(replies_count: 0) }
  scope :popular,            -> { where("likes_count > 5") }
  scope :without_ban,        -> { where.not(grade: :ban) }
  scope :without_hide_nodes, -> { exclude_column_ids("node_id", Topic.topic_index_hide_node_ids) }

  scope :without_node_ids,   ->(ids) { exclude_column_ids("node_id", ids) }
  scope :without_users,      ->(ids) { exclude_column_ids("user_id", ids) }
  scope :exclude_column_ids, ->(column, ids) { ids.empty? ? all : where.not(column => ids) }

  scope :without_nodes, lambda { |node_ids|
    ids = node_ids + Topic.topic_index_hide_node_ids
    ids.uniq!
    exclude_column_ids("node_id", ids)
  }
  scope :without_draft, -> { where(draft: false) }

  before_save { self.node_name = node.try(:name) || "" }
  before_create { self.last_active_mark = Time.now.to_i }

  def self.fields_for_list
    columns = %w[body who_deleted]
    select(column_names - columns.map(&:to_s))
  end

  def full_body
    ([self.body] + self.replies.pluck(:body)).join('\n\n')
  end

  def self.topic_index_hide_node_ids
    Setting.node_ids_hide_in_topics_index.collect(&:to_i)
  end

  # 所有的回复编号
  def reply_ids
    Rails.cache.fetch([self, "reply_ids"]) do
      self.replies.order("id asc").pluck(:id)
    end
  end

  def update_last_reply(reply, force: false)
    # replied_at 用于最新回复的排序，如果帖着创建时间在一个月以前，就不再往前面顶了
    return false if reply.blank? && !force

    self.last_active_mark      = Time.now.to_i if created_at > 1.month.ago
    self.replied_at            = reply.try(:created_at)
    self.replies_count         = replies.without_system.count
    self.last_reply_id         = reply.try(:id)
    self.last_reply_user_id    = reply.try(:user_id)
    self.last_reply_user_login = reply.try(:user_login)

    save
  end

  # 更新最后更新人，当最后个回帖删除的时候
  def update_deleted_last_reply(deleted_reply)
    return false if deleted_reply.blank?
    return false if last_reply_user_id != deleted_reply.user_id

    previous_reply = replies.without_system.where.not(id: deleted_reply.id).recent.first
    update_last_reply(previous_reply, force: true)
  end

  def floor_of_reply(reply)
    reply_index = reply_ids.index(reply.id)
    reply_index + 1
  end

  def check_topic_ban_words
    ban_words = Setting.ban_words_in_body.collect(&:strip)
    ban_words.each do |word|
      if body.include?(word)
        errors.add(:body, "敏感词 “#{word}” 禁止发布！")
        return false
      end
    end
  end

  def self.total_pages
    return @total_pages if defined? @total_pages

    total_count = Rails.cache.fetch("topics/total_count", expires_in: 1.week) do
      self.unscoped.count
    end
    if total_count >= 1500
      @total_pages = 60
    end
    @total_pages
  end
end
