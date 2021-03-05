# frozen_string_literal: true

class Topic < ApplicationRecord
  include UserAvatarDelegate
  include Searchable
  include Closeable
  include MentionTopic
  include Mentionable
  include MarkdownBody
  include SoftDelete
  include Topic::RateLimit
  include Topic::Notify
  include Topic::Search
  include Topic::AutoCorrect
  include Topic::Actions

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
  delegate :name, to: :node, prefix: true, allow_nil: true

  # scopes
  scope :last_actived, -> { order(last_active_mark: :desc) }
  scope :suggest, -> { where("suggested_at IS NOT NULL").order(suggested_at: :desc) }
  scope :without_suggest, -> { where(suggested_at: nil) }
  scope :high_likes, -> { order(likes_count: :desc).order(id: :desc) }
  scope :high_replies, -> { order(replies_count: :desc).order(id: :desc) }
  scope :last_reply, -> { where("last_reply_id IS NOT NULL").order(last_reply_id: :desc) }
  scope :no_reply, -> { where(replies_count: 0) }
  scope :popular, -> { where("likes_count > 5") }
  scope :without_ban, -> { where.not(grade: :ban) }
  scope :without_hide_nodes, -> { exclude_column_ids("node_id", Topic.topic_index_hide_node_ids) }

  scope :without_node_ids, ->(ids) { exclude_column_ids("node_id", ids) }
  scope :without_users, ->(ids) { exclude_column_ids("user_id", ids) }
  scope :exclude_column_ids, ->(column, ids) { ids.empty? ? all : where.not(column => ids) }

  scope :without_nodes, lambda { |node_ids|
    ids = node_ids + Topic.topic_index_hide_node_ids
    ids.uniq!
    exclude_column_ids("node_id", ids)
  }

  before_create { self.last_active_mark = Time.now.to_i }

  def self.fields_for_list
    columns = %w[body who_deleted]
    select(column_names - columns.map(&:to_s))
  end

  def full_body
    ([body] + replies.pluck(:body)).join('\n\n')
  end

  def self.topic_index_hide_node_ids
    Setting.node_ids_hide_in_topics_index.collect(&:to_i)
  end

  # All reply ids
  def reply_ids
    Rails.cache.fetch([self, "reply_ids"]) do
      replies.order("id asc").pluck(:id)
    end
  end

  # Update the topic last reply
  # Ignore this method if Topic has created at 1 month ago
  def update_last_reply(reply, force: false)
    return false if reply.blank? && !force

    self.last_active_mark = Time.now.to_i if created_at > 1.month.ago
    self.replied_at = reply.try(:created_at)
    self.replies_count = replies.without_system.count
    self.last_reply_id = reply.try(:id)
    self.last_reply_user_id = reply.try(:user_id)
    self.last_reply_user_login = reply.try(:user_login)

    save
  end

  # Update last update user, when reply deleting
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
        errors.add(:body, I18n.t("topics.sensitive_word_limit", word: word))
        return false
      end
    end
  end

  def self.total_pages
    return @total_pages if defined? @total_pages

    total_count = Rails.cache.fetch("topics/total_count", expires_in: 1.week) do
      unscoped.count
    end
    if total_count >= 1500
      @total_pages = 60
    end
    @total_pages
  end
end
