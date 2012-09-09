# coding: utf-8
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
  field :last_reply_id, :type => Integer
  field :replied_at , :type => DateTime
  field :source
  field :message_id
  field :replies_count, :type => Integer, :default => 0
  # 回复过的人的 ids 列表
  field :follower_ids, :type => Array, :default => []
  field :suggested_at, :type => DateTime
  # 最后回复人的用户名 - cache 字段用于减少列表也的查询
  field :last_reply_user_login
  # 节点名称 - cache 字段用于减少列表也的查询
  field :node_name
  # 删除人
  field :who_deleted

  belongs_to :user, :inverse_of => :topics
  counter_cache :name => :user, :inverse_of => :topics
  belongs_to :node
  counter_cache :name => :node, :inverse_of => :topics
  belongs_to :last_reply_user, :class_name => 'User'
  has_many :replies, :dependent => :destroy

  attr_accessible :title, :body
  validates_presence_of :user_id, :title, :body, :node_id

  index :node_id => 1
  index :user_id => 1
  index :replied_at => -1,:_id => -1
  index :likes_count => 1
  index :suggested_at => 1

  counter :hits, :default => 0
  
  delegate :login, :to => :user, :prefix => true, :allow_nil => true

  # scopes
  scope :last_actived, desc("replied_at").desc(:_id)
  # 推荐的话题
  scope :suggest, where(:suggested_at.ne => nil).desc(:suggested_at)
  scope :fields_for_list, without(:body,:body_html)
  scope :high_likes, desc(:likes_count, :_id)
  scope :high_replies, desc(:replies_count, :_id)
  scope :no_reply, where(:replies_count => 0)
  scope :popular, where(:likes_count.gt => 5)
  # scope :without_node_ids, Proc.new { |ids| where(:node_id.nin = ids) }

  def self.find_by_message_id(message_id)
    where(:message_id => message_id).first
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

  before_create :init_replied_at_on_create
  def init_replied_at_on_create
    self.replied_at = Time.now if self.replied_at.blank?
  end

  def push_follower(uid)
    return false if uid == self.user_id
    return false if self.follower_ids.include?(uid)
    self.push(:follower_ids,uid)
  end

  def pull_follower(uid)
    return false if uid == self.user_id
    self.pull(:follower_ids,uid)
  end

  def update_last_reply(reply)
    self.replied_at = Time.now
    self.last_reply_id = reply.id
    self.last_reply_user_id = reply.user_id
    self.last_reply_user_login = reply.user.try(:login) || nil
    self.save
  end
  
  def last_reply
    return nil if self.last_reply_id.nil?
    Reply.find(self.last_reply_id)
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
end
