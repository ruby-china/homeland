# coding: utf-8
require "auto-space"
class Topic
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel
  include Mongoid::SoftDelete
  include Mongoid::CounterCache
  include Mongoid::Likeable
  include Mongoid::MarkdownBody
  include Redis::Objects
  include Mongoid::Mentionable

  field :title
  field :body
  field :body_html
  field :last_reply_id, type: Integer
  field :replied_at , type: DateTime
  field :source
  field :message_id
  field :replies_count, type: Integer, default: 0
  # 回复过的人的 ids 列表
  field :follower_ids, type: Array, default: []
  field :suggested_at, type: DateTime
  # 最后回复人的用户名 - cache 字段用于减少列表也的查询
  field :last_reply_user_login
  # 节点名称 - cache 字段用于减少列表也的查询
  field :node_name
  # 删除人
  field :who_deleted
  # 用于排序的标记
  field :last_active_mark, type: Integer
  # 是否锁定节点
  field :lock_node, type: Mongoid::Boolean, default: false
  # 精华帖 0 否， 1 是
  field :excellent, type: Integer, default: 0

  # 临时存储检测用户是否读过的结果
  attr_accessor :read_state

  belongs_to :user, inverse_of: :topics
  counter_cache name: :user, inverse_of: :topics
  belongs_to :node
  counter_cache name: :node, inverse_of: :topics
  belongs_to :last_reply_user, class_name: 'User'
  belongs_to :last_reply, class_name: 'Reply'
  has_many :replies, dependent: :destroy

  validates_presence_of :user_id, :title, :body, :node

  index node_id: 1
  index user_id: 1
  index last_active_mark: -1
  index likes_count: 1
  index suggested_at: 1
  index excellent: -1

  counter :hits, default: 0

  HOURS_IN_DAY = 24
  UPDATES_IN_HOUR = 6
  DAYS_IN_WEEK = 7
  UPDATES_IN_DAY = 24
  REPLY_WEIGHT = 3

  counter :count_in_hour, default: 0
  value :daily_hits_hour_ago, default: 0
  value :daily_score_hour_ago, default: 0
  list :daily_hits, maxlength: (HOURS_IN_DAY - 1)
  value :daily_replies_hour_ago, default: 0
  list :daily_replies, maxlength: (HOURS_IN_DAY - 1)

  counter :count_in_day, default: 0
  value :weekly_hits_day_ago, default: 0
  value :weekly_score_day_ago, default: 0
  list :weekly_hits, maxlength: (DAYS_IN_WEEK - 1)
  value :weekly_replies_day_ago, default: 0
  list :weekly_replies, maxlength: (DAYS_IN_WEEK - 1)

  field :daily_score, type: Integer, default: 0
  field :weekly_score, type: Integer, default: 0
  index weekly_score: -1
  index daily_score: -1

  delegate :login, to: :user, prefix: true, allow_nil: true
  delegate :body, to: :last_reply, prefix: true, allow_nil: true

  # scopes
  scope :last_actived, -> {  desc(:last_active_mark) }
  # 推荐的话题
  scope :suggest, -> { where(:suggested_at.ne => nil).desc(:suggested_at) }
  scope :fields_for_list, -> { without(:body,:body_html) }
  scope :high_likes, -> { desc(:likes_count, :_id) }
  scope :high_replies, -> { desc(:replies_count, :_id) }
  scope :no_reply, -> { where(replies_count: 0) }
  scope :popular, -> { where(:likes_count.gt => 5) }
  scope :without_node_ids, Proc.new { |ids| where(:node_id.nin => ids) }
  scope :excellent, -> { where(:excellent.gte => 1) }
  # 热门话题
  scope :daily_hot_topics, -> { desc(:daily_score).limit(100) }
  scope :weekly_hot_topics, -> { desc(:weekly_score).limit(100) }

  def self.find_by_message_id(message_id)
    where(message_id: message_id).first
  end

  # 排除隐藏的节点
  def self.without_hide_nodes
    where(:node_id.nin => self.topic_index_hide_node_ids)
  end

  def self.topic_index_hide_node_ids
    SiteConfig.node_ids_hide_in_topics_index.to_s.split(",").collect { |id| id.to_i }
  end

  before_save :store_cache_fields
  def store_cache_fields
    self.node_name = self.node.try(:name) || ""
  end
  before_save :auto_space_with_title
  def auto_space_with_title
    self.title.auto_space!
  end

  before_create :init_last_active_mark_on_create
  def init_last_active_mark_on_create
    self.last_active_mark = Time.now.to_i
  end

  def push_follower(uid)
    return false if uid == self.user_id
    return false if self.follower_ids.include?(uid)
    self.push(follower_ids: uid)
    true
  end

  def pull_follower(uid)
    return false if uid == self.user_id
    self.pull(follower_ids: uid)
    true
  end

  def update_last_reply(reply, opts = {})
    # replied_at 用于最新回复的排序，如果帖着创建时间在一个月以前，就不再往前面顶了
    return false if reply.blank? && !opts[:force]

    self.last_active_mark = Time.now.to_i if self.created_at > 1.month.ago
    self.replied_at = reply.try(:created_at)
    self.last_reply_id = reply.try(:id)
    self.last_reply_user_id = reply.try(:user_id)
    self.last_reply_user_login = reply.try(:user_login)
    self.save
  end

  # 更新最后更新人，当最后个回帖删除的时候
  def update_deleted_last_reply(deleted_reply)
    return false if deleted_reply.blank?
    return false if self.last_reply_user_id != deleted_reply.user_id

    previous_reply = self.replies.where(:_id.nin => [deleted_reply.id]).recent.first
    self.update_last_reply(previous_reply, force: true)
  end

  # 删除并记录删除人
  def destroy_by(user)
    return false if user.blank?
    self.update_attribute(:who_deleted,user.login)
    self.destroy
  end

  def destroy
    super
    delete_notifiaction_mentions
  end

  def last_page_with_per_page(per_page)
    page = (self.replies_count.to_f / per_page).ceil
    page > 1 ? page : nil
  end

  # 所有的回复编号
  def reply_ids
    Rails.cache.fetch([self,"reply_ids"]) do
      self.replies.only(:_id).map(&:_id)
    end
  end

  def excellent?
    self.excellent >= 1
  end

  def self.update_daily_hot_topics
    Topic.daily_hot_topics.each { |topic| topic.update_daily_hot_topics }
  end

  def self.update_weekly_hot_topics
    Topic.weekly_hot_topics.each { |topic| topic.update_weekly_hot_topics }
  end

  def update_daily_score
    self.daily_score, hits_in_hour, replies_in_hour = calc_score(
      daily_hits_hour_ago.value.to_i,
      daily_replies_hour_ago.value.to_i,
      daily_score_hour_ago.value.to_i,
      HOURS_IN_DAY, REPLY_WEIGHT
    )
    [hits_in_hour, replies_in_hour]
  end

  def update_weekly_score
    self.weekly_score, hits_in_day, replies_in_day = calc_score(
      weekly_hits_day_ago.value.to_i,
      weekly_replies_day_ago.value.to_i,
      weekly_score_day_ago.value.to_i,
      DAYS_IN_WEEK, REPLY_WEIGHT
    )
    [hits_in_day, replies_in_day]
  end

  def update_score
    update_daily_score
    update_weekly_score
    save!
  end

  # 更新每日热门话题
  def update_daily_hot_topics
    # 计算当前时间段查看数，回复数
    hits_in_hour, replies_in_hour = update_daily_score
    if count_in_hour.value == UPDATES_IN_HOUR - 1 #整一个小时
      # 储存每小时的查看数，回复数
      self.daily_hits.unshift(hits_in_hour)
      self.daily_replies.unshift(replies_in_hour)
      # 计算分数
      self.daily_score_hour_ago = calc_old_score(daily_hits, daily_replies, HOURS_IN_DAY-1, REPLY_WEIGHT)
      # 储存总查看数，回复数
      self.daily_hits_hour_ago.value = hits.value
      self.daily_replies_hour_ago.value = replies_count
      # 计数器清零
      self.count_in_hour.reset
    else
      self.count_in_hour.incr(1)
    end
    # require 'pry'; binding.pry
    save!
  end

  # 更新每周热门话题
  def update_weekly_hot_topics
    # 计算当前时间段查看数，回复数
    hits_in_day, replies_in_day = update_weekly_score
    if count_in_day.value == UPDATES_IN_DAY - 1 # 整一周
      # 储存每小时的查看数，回复数
      self.weekly_hits.unshift(hits_in_day)
      self.weekly_replies.unshift(replies_in_day)
      # 计算分数
      self.weekly_score_day_ago = calc_old_score(weekly_hits, weekly_replies, DAYS_IN_WEEK-1, REPLY_WEIGHT)
      # 储存总查看数，回复数
      self.weekly_hits_day_ago.value = hits.value
      self.weekly_replies_day_ago.value = replies_count
      # 计数器清零
      self.count_in_day.reset
    else
      self.count_in_day.incr(1)
    end
    save!
  end

  # 计算分数
  def calc_score(old_hits, old_replies, old_score, length, weight)
    hits_diff = hits.value - old_hits
    replies_diff = replies_count - old_replies
    score = (hits_diff + replies_diff*weight)*length + old_score
    [score, hits_diff, replies_diff]
  end

  def calc_old_score(list0, list1, length, weight)
    score = list0.each.with_index.inject(0) { |sum, (el, index)| sum + el.to_i*(length-index) }
    score += weight*list1.each.with_index.inject(0) { |sum, (el, index)| sum + el.to_i*(length-index) }
    score
  end

end
