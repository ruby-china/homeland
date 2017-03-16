module Mentionable
  extend ActiveSupport::Concern

  included do
    before_save :extract_mentioned_users
    after_create :send_mention_notification
    after_destroy :delete_notifiaction_mentions
  end

  def delete_notifiaction_mentions
    Notification.where(notify_type: 'mention', target: self).delete_all
  end

  def mentioned_users
    User.where(id: mentioned_user_ids)
  end

  def mentioned_user_logins
    # 用于作为缓存 key
    ids_md5 = Digest::MD5.hexdigest(mentioned_user_ids.to_s)
    Rails.cache.fetch("#{self.class.name.downcase}:#{id}:mentioned_user_logins:#{ids_md5}") do
      User.where(id: mentioned_user_ids).pluck(:login)
    end
  end

  def extract_mentioned_users
    logins = body.scan(/@([#{User::LOGIN_FORMAT}]{3,20})/).flatten.map(&:downcase)
    if logins.any?
      self.mentioned_user_ids = User.where('lower(login) IN (?) AND id != (?)', logins, user.id).limit(5).pluck(:id)
    end

    # add Reply to user_id
    if self.respond_to?(:reply_to)
      reply_to_user_id = self.reply_to&.user_id
      if reply_to_user_id
        self.mentioned_user_ids << reply_to_user_id
      end
    end
  end

  def no_mention_users
    [user]
  end

  def send_mention_notification
    users = mentioned_users - no_mention_users
    Notification.bulk_insert(set_size: 100) do |worker|
      users.each do |user|
        note = {
          notify_type: 'mention',
          actor_id: self.user_id,
          user_id: user.id,
          target_type: self.class.name,
          target_id: self.id
        }
        if self.class.name == 'Reply'
          note[:second_target_type] = 'Topic'
          note[:second_target_id] = self.send(:topic_id)
        elsif self.class.name == 'Comment'
          note[:second_target_type] = self.commentable_type
          note[:second_target_id] = self.commentable_id
        end
        worker.add(note)
      end
    end

    # Touch push to client
    # TODO: 确保准确
    users.each do |u|
      n = u.notifications.last
      n.realtime_push_to_client
    end
  end
end
