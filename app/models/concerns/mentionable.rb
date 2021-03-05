# frozen_string_literal: true

module Mentionable
  extend ActiveSupport::Concern

  included do
    before_save :extract_mentioned_users
    after_create :send_mention_notification
    after_destroy :delete_notification_mentions
  end

  def delete_notification_mentions
    Notification.where(notify_type: "mention", target: self).delete_all
  end

  def mentioned_users
    User.without_team.where(id: mentioned_user_ids)
  end

  def mentioned_user_logins
    # as cache key
    ids_md5 = Digest::MD5.hexdigest(mentioned_user_ids.to_s)
    Rails.cache.fetch("#{self.class.name.downcase}:#{id}:mentioned_user_logins:#{ids_md5}") do
      mentioned_users.pluck(:login)
    end
  end

  def extract_mentioned_users
    logins = body.scan(/@([#{User::LOGIN_FORMAT}]{3,20})/o).flatten.map(&:downcase)
    logins.delete(user.login.downcase) if user

    if logins.any?
      self.mentioned_user_ids = User.without_team.where("lower(login) IN (?)", logins).limit(5).pluck(:id)
    end

    # add Reply to user_id
    if respond_to?(:reply_to)
      reply_to_user_id = reply_to&.user_id
      if reply_to_user_id
        mentioned_user_ids << reply_to_user_id
      end
    end
  end

  private

  def no_mention_users
    [user]
  end

  def send_mention_notification
    users = mentioned_users - no_mention_users

    all_records = users.map do |user|
      note = {
        notify_type: "mention",
        actor_id: user_id,
        user_id: user.id,
        target_type: self.class.name,
        target_id: id,
        created_at: Time.now,
        updated_at: Time.now
      }
      if instance_of?(Reply)
        note[:second_target_type] = "Topic"
        note[:second_target_id] = send(:topic_id)
      elsif instance_of?(Comment)
        note[:second_target_type] = commentable_type
        note[:second_target_id] = commentable_id
      end
      note
    end

    all_records.each_slice(100) do |records|
      Notification.insert_all(records)
    end

    # Touch push to client
    # TODO: 确保准确
    users.each do |u|
      n = u.notifications.last
      n.realtime_push_to_client
    end
  end
end
