# coding: utf-8
require "digest/md5"
class Reply
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel
  include Mongoid::CounterCache
  include Mongoid::SoftDelete
  include Mongoid::MarkdownBody

  field :body
  field :body_html
  field :source
  field :message_id
  field :mentioned_user_ids, :type => Array, :default => []

  belongs_to :user, :inverse_of => :replies
  belongs_to :topic, :inverse_of => :replies
  has_many :notifications, :class_name => 'Notification::Base', :dependent => :delete

  counter_cache :name => :user, :inverse_of => :replies
  counter_cache :name => :topic, :inverse_of => :replies

  index :user_id
  index :topic_id

  attr_accessible :body

  validates_presence_of :body

  after_create :update_parent_topic
  def update_parent_topic
    topic.update_last_reply(self)
  end

  # 更新的时候也更新话题的 updated_at 以便于清理缓存之类的东西
  after_update :update_parent_topic_updated_at
  def update_parent_topic_updated_at
    if not self.topic.blank?
      self.topic.update_attribute(:updated_at, Time.now)
    end
  end

  before_save :extract_mentioned_users
  def extract_mentioned_users
    logins = body.scan(/@(\w{3,20})/).flatten
    if logins.any?
      self.mentioned_user_ids = User.where(:login => /^(#{logins.join('|')})$/i, :_id.ne => user.id).limit(5).only(:_id).map(&:_id).to_a
    end
  end

  def mentioned_user_logins
    # 用于作为缓存 key
    ids_md5 = Digest::MD5.hexdigest(self.mentioned_user_ids.to_s)
    Rails.cache.fetch("reply:#{self.id}:mentioned_user_logins:#{ids_md5}") do
      User.where(:_id.in => self.mentioned_user_ids).only(:login).map(&:login)
    end
  end

  after_create :send_mention_notification, :send_topic_reply_notification
  def send_mention_notification
    self.mentioned_user_ids.each do |user_id|
      Notification::Mention.create :user_id => user_id, :reply => self
    end
  end

  def send_topic_reply_notification
    if self.user != topic.user && !mentioned_user_ids.include?(topic.user_id)
      Notification::TopicReply.create :user => topic.user, :reply => self
    end
  end

  def destroy
    super
    notifications.delete_all
  end
end
