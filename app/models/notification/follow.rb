# coding: utf-8
class Notification::Follow < Notification::Base
  belongs_to :follower, class_name: "User"
  
  def self.notify(opts = {})
    user = opts[:user]
    follower = opts[:follower]
    return false if user.blank? or follower.blank?
    return false if user.id == follower.id
    
    if Notification::Follow.where(user_id: user.id, follower_id: follower.id).count == 0
      Notification::Follow.create(user: user, follower: follower)
    end
  end
  
  def actor
    self.follower
  end
  
  def notify_hash
    return {} if self.follower.blank?
    {
      title: [self.follower.login, '关注了你'].join(' '),
      content: '',
      content_path: self.content_path
    }
  end

  def content_path
    url_helpers.user_path(self.follower.login.downcase)
  end
end
