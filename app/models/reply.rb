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

  field :body
  field :body_html
  field :source
  field :message_id

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
    if self.user != topic.user && !mentioned_user_ids.include?(topic.user_id)
      Notification::TopicReply.create :user => topic.user, :reply => self
    end
  end

  def destroy
    super
    notifications.delete_all
    delete_notifiaction_mentions
  end
end
