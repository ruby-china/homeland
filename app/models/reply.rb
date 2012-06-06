# coding: utf-8
require "digest/md5"
class Reply
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel
  include Mongoid::CounterCache
  include Mongoid::SoftDelete
  include Mongoid::MarkdownBody
  include Mongoid::Mentionable
  include Mongoid::Likeable

  field :body
  field :body_html
  field :source
  field :message_id
  field :likes_count, :type => Integer, :default => 0

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

  after_create :send_topic_reply_notification
  def send_topic_reply_notification
    # 给发帖人发回帖通知
    if self.user != topic.user && !mentioned_user_ids.include?(topic.user_id)
      Notification::TopicReply.create :user => topic.user, :reply => self
      self.notified_user_ids << topic.user_id
    end

    # 给关注者发通知
    self.topic.follower_ids.each do |uid|
      # 排除同一个回复过程中已经提醒过的人
      next if self.notified_user_ids.include?(uid)
      # 排除回帖人
      next if uid == self.user_id
      Notification::TopicReply.create :user_id => uid, :reply => self
    end
  end

  # 是否热门
  def popular?
    self.likes_count >= 5
  end

  def destroy
    super
    notifications.delete_all
    delete_notifiaction_mentions
  end
end
