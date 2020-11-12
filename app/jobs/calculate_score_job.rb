# frozen_string_literal: true

class CalculateScoreJob < ApplicationJob
  sidekiq_options lock: :until_executing

  def perform(type, target_id)
    if type.to_s == "Reply"
      reply = Reply.find_by_id(target_id)
      return unless reply
      score = BlackBox.calc_reply_quality_score(reply)
      reply.update_columns(score: score)
    else
      topic = Topic.find_by_id(target_id)
      return unless topic
      score = BlackBox.hotness_score(topic)
      topic.update_columns(score: score)
    end
  end
end
