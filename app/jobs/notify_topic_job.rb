# frozen_string_literal: true

class NotifyTopicJob < ApplicationJob
  queue_as :notifications

  def perform(topic_id)
    topic = Topic.find_by_id(topic_id)
    return if topic&.user.blank?
    return if topic.draft

    follower_ids = topic.user.follow_by_user_ids
    return if follower_ids.empty?

    # 私密组织，组内广播
    if topic.private_org
      follower_ids = topic&.team.team_notify_users.pluck(:user_id) || []
    end

    # 对于专题文章来说只通知关注了该专题的用户
    if topic.is_article?
      column_focus_user_ids = topic.column.follow_by_user_ids || []
      follower_ids = follower_ids | column_focus_user_ids
    end

    notified_user_ids = topic.mentioned_user_ids

    # 给关注者发通知
    default_note = { notify_type: "topic", target_type: "Topic", target_id: topic.id, actor_id: topic.user_id }
    Notification.bulk_insert(set_size: 100) do |worker|
      follower_ids.each do |uid|
        # 排除同一个回复过程中已经提醒过的人
        next if notified_user_ids.include?(uid)
        # 排除回帖人
        next if uid == topic.user_id
        note = default_note.merge(user_id: uid)
        worker.add(note)
      end
    end
  end
end
