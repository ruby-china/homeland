require 'auto-space'

CORRECT_CHARS = [
  ['【', '['],
  ['】', ']'],
  ['（', '('],
  ['）', ')']
]

class Topic < ActiveRecord::Base
  include Redis::Objects
  include BaseModel
  include Likeable
  include MarkdownBody
  include SoftDelete

  # 临时存储检测用户是否读过的结果
  attr_accessor :read_state, :admin_editing

  belongs_to :user, inverse_of: :topics, counter_cache: true
  belongs_to :node, counter_cache: true
  belongs_to :last_reply_user, class_name: 'User'
  belongs_to :last_reply, class_name: 'Reply'
  has_many :replies, dependent: :destroy

  validates :user_id, :title, :body, :node_id, presence: true

  counter :hits, default: 0

  delegate :login, to: :user, prefix: true, allow_nil: true
  delegate :body, to: :last_reply, prefix: true, allow_nil: true

  # scopes
  scope :last_actived, -> { order(last_active_mark: :desc) }
  # 推荐的话题
  scope :suggest, -> { where("suggested_at IS NOT NULL").order(suggested_at: :desc) }
  scope :without_suggest, -> { where(suggested_at: nil) }
  scope :high_likes, -> { order(likes_count: :desc).order(id: :desc) }
  scope :high_replies, -> { order(replies_count: :desc).order(id: :desc) }
  scope :no_reply, -> { where(replies_count: 0) }
  scope :popular, -> { where("likes_count > 5") }
  scope :exclude_column_ids, proc {|column, ids|
    if ids.size == 0
      all
    else
      where("#{column} NOT IN (?)", ids)
    end
  }
  scope :without_node_ids, proc { |ids| exclude_column_ids("node_id", ids) }
  scope :excellent, -> { where("excellent >= 1") }
  scope :without_hide_nodes, -> { exclude_column_ids("node_id", Topic.topic_index_hide_node_ids) }
  scope :without_nodes, proc { |node_ids|
    ids = node_ids + Topic.topic_index_hide_node_ids
    ids.uniq!
    exclude_column_ids("node_id", ids)
  }
  scope :without_users, proc { |user_ids|
    exclude_column_ids("user_id", user_ids)
  }
  scope :without_body, -> { select(column_names - ['body'])}

  def self.fields_for_list
    columns = %w(body body_html who_deleted follower_ids)
    select(column_names - columns.map(&:to_s))
  end

  def full_body
    ([self.body] + self.replies.pluck(:body)).join('\n\n')
  end

  def self.topic_index_hide_node_ids
    SiteConfig.node_ids_hide_in_topics_index.to_s.split(',').collect(&:to_i)
  end

  before_save :store_cache_fields
  def store_cache_fields
    self.node_name = node.try(:name) || ''
  end

  before_save :auto_correct_title
  def auto_correct_title
    CORRECT_CHARS.each do |chars|
      title.gsub!(chars[0], chars[1])
    end
    title.auto_space!
  end
  before_save do
    if admin_editing == true && self.node_id_changed?
      self.class.notify_topic_node_changed(id, node_id)
    end
  end

  before_create :init_last_active_mark_on_create
  def init_last_active_mark_on_create
    self.last_active_mark = Time.now.to_i
  end

  after_create do
    NotifyTopicJob.perform_later(id)
  end

  def followed?(uid)
    follower_ids.include?(uid)
  end

  def push_follower(uid)
    return false if uid == user_id
    return false if followed?(uid)
    push(follower_ids: uid)
    true
  end

  def pull_follower(uid)
    return false if uid == user_id
    pull(follower_ids: uid)
    true
  end

  def update_last_reply(reply, opts = {})
    # replied_at 用于最新回复的排序，如果帖着创建时间在一个月以前，就不再往前面顶了
    return false if reply.blank? && !opts[:force]

    self.last_active_mark = Time.now.to_i if created_at > 1.month.ago
    self.replied_at = reply.try(:created_at)
    self.last_reply_id = reply.try(:id)
    self.last_reply_user_id = reply.try(:user_id)
    self.last_reply_user_login = reply.try(:user_login)
    # Reindex Search document
    SearchIndexer.perform_later('update', 'topic', self.id)
    save
  end

  # 更新最后更新人，当最后个回帖删除的时候
  def update_deleted_last_reply(deleted_reply)
    return false if deleted_reply.blank?
    return false if last_reply_user_id != deleted_reply.user_id

    previous_reply = replies.where("id NOT IN (?)", [deleted_reply.id]).recent.first
    update_last_reply(previous_reply, force: true)
  end

  # 删除并记录删除人
  def destroy_by(user)
    return false if user.blank?
    update_attribute(:who_deleted, user.login)
    destroy
  end

  def destroy
    super
    delete_notifiaction_mentions
  end

  # 所有的回复编号
  def reply_ids
    Rails.cache.fetch([self, 'reply_ids']) do
      replies.only(:id).map(&:id).sort
    end
  end

  def excellent?
    excellent >= 1
  end

  def ban!
    update_attributes(lock_node: true, node_id: Node.no_point_id, admin_editing: true)
  end

  def floor_of_reply(reply)
    reply_index = reply_ids.index(reply.id)
    reply_index + 1
  end

  def self.notify_topic_created(topic_id)
    topic = Topic.find_by_id(topic_id)
    return if topic.blank?

    notified_user_ids = topic.mentioned_user_ids

    follower_ids = (topic.user.try(:follower_ids) || [])
    follower_ids.uniq!

    # 给关注者发通知
    follower_ids.each do |uid|
      # 排除同一个回复过程中已经提醒过的人
      next if notified_user_ids.include?(uid)
      # 排除回帖人
      next if uid == topic.user_id
      logger.debug "Post Notification to: #{uid}"
      Notification::Topic.create user_id: uid, topic_id: topic.id
    end
    true
  end

  def self.notify_topic_node_changed(topic_id, node_id)
    topic = Topic.find_by_id(topic_id)
    return if topic.blank?
    node = Node.find_by_id(node_id)
    return if node.blank?

    Notification::NodeChanged.create user_id: topic.user_id, topic_id: topic_id, node_id: node_id
    true
  end
end
