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
    logins = body.scan(/@([A-Za-z0-9\-\_\.]{3,20})/).flatten.map(&:downcase)
    if logins.any?
      self.mentioned_user_ids = User.where('lower(login) IN (?) AND id != (?)', logins, user.id).limit(5).pluck(:id)
    end
  end

  def no_mention_users
    [user]
  end

  def send_mention_notification
    Notification.bulk_insert(set_size: 100) do |worker|
      (mentioned_users - no_mention_users).each do |user|
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
        end
        worker.add(note)
      end
    end
  end
end
