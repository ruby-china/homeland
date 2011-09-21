# coding: utf-8  
class Reply
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body
  field :source  
  
  belongs_to :user, :inverse_of => :replies
  belongs_to :topic, :inverse_of => :replies
  
  attr_protected :user_id, :topic_id

  validates_presence_of :body
  scope :recents, :order => "id desc"
  after_create :update_parent_last_replied
  after_create :send_got_reply_mail
  def update_parent_last_replied
    self.topic.replied_at = Time.now
    self.topic.last_reply_user_id = self.user_id
    self.topic.replies_count = self.topic.replies.count
    self.topic.save
    # 清除用户读过记录
    self.topic.clear_user_readed
  end
  def send_got_reply_mail
    m = TopicMailer.create_got_reply(self.topic,self)
    Thread.new { m.deliver }
  end  
  
  def self.cached_count
    return Rails.cache.fetch("replies/count",:expires_in => 1.hours) do
      self.count
    end
  end
end
