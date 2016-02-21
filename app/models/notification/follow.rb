module Notification
  class Follow < Base
    belongs_to :follower, class_name: 'User'

    def self.notify(opts = {})
      user = opts[:user]
      follower = opts[:follower]
      return false if user.blank? || follower.blank?
      return false if user.id == follower.id

      if Notification::Follow.where(user_id: user.id, follower_id: follower.id).count == 0
        Notification::Follow.create(user: user, follower: follower)
      end
    end

    def actor
      follower
    end

    def notify_hash
      return {} if follower.blank?
      {
        title: [follower.login, '开关注你了'].join(' '),
        content: '',
        content_path: content_path
      }
    end

    def content_path
      url_helpers.user_path(follower)
    end
  end
end
