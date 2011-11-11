# coding: utf-8  
class Reply
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel
  include Mongoid::SoftDelete

  field :body
  field :source  
  field :message_id
  field :mentioned_user_ids, :type => Array, :default => []
  
  belongs_to :user, :inverse_of => :replies
  belongs_to :topic, :inverse_of => :replies
  
  index :user_id
  index :topic_id
  
  attr_protected :user_id, :topic_id

  validates_presence_of :body
  after_create :update_parent_topic
  def update_parent_topic
    self.topic.replied_at = Time.now
    self.topic.last_reply_user_id = self.user_id
    self.topic.replies_count += 1
    self.topic.push_follower(self.user_id)
    self.topic.save
    # 清除用户读过记录
    self.topic.clear_user_readed
  end
  
  after_create :send_mail_notify
  def send_mail_notify
    TopicMailer.got_reply(self)
  end
  
  def self.cached_count
    return Rails.cache.fetch("replies/count",:expires_in => 1.hours) do
      self.count
    end
  end

  before_save :extract_mentioned_users
  def extract_mentioned_users
    logins = body.scan(/@(\w{3,20})/).flatten
    if logins.any?
      self.mentioned_user_ids = User.where(:login => /^(#{logins.join('|')})$/i, :_id.ne => user.id).limit(5).only(:_id).map(&:_id).to_a
    end
  end

  def mentioned_users
    if mentioned_user_ids.any?
      User.where(:_id.in => mentioned_user_ids)
    else
      []
    end
  end

  after_create :send_mention_notification
  def send_mention_notification
    mentioned_users.each do |user|
      Notification::Mention.create :user => user, :reply => self
    end
  end
end
