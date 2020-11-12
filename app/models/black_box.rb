# https://github.com/forem/forem/blob/dc91840a713afc01bee35d469f484125c2d41ce4/app/black_box/black_box.rb
class BlackBox
  EPOCH_NUMBER = "2010-01-01 00:00:01".to_time.to_i

  class << self
    def hotness_score(topic)
      usable_date = topic.created_at

      super_super_recent_bonus = usable_date > 1.hour.ago ? 28 : 0
      super_recent_bonus = usable_date > 8.hours.ago ? 81 : 0
      recency_bonus = usable_date > 12.hours.ago ? 280 : 0
      today_bonus = usable_date > 24.hours.ago ? 795 : 0
      two_day_bonus = usable_date > 48.hours.ago ? 830 : 0
      four_day_bonus = usable_date > 96.hours.ago ? 930 : 0

      topic_score = calc_topic_score(topic)

      (
        topic_score + recency_bonus + super_recent_bonus +
        super_super_recent_bonus + today_bonus + two_day_bonus + four_day_bonus
      )
    end

    def calc_topic_score(topic)
      score_from_epoch = topic.created_at.to_i - EPOCH_NUMBER
      topic_score = calc_topic_quality_score(topic)
      reply_score = topic.replies.sum(:score)
      score_from_epoch / 1000 +
        ([topic_score, 650].min * 2) +
        ([reply_score, 650].min * 2)
      # - (article.spaminess_rating * 5)
    end

    def calc_topic_quality_score(topic)
      likes_points = topic.likes_count
      rep_points = topic.replies_count
      bonus_points = calculate_bonus_score(topic.body)
      spaminess_rating = calculate_spaminess(topic)
      (likes_points + rep_points + bonus_points - spaminess_rating).to_i
    end

    def calc_reply_quality_score(reply)
      rep_points = reply.likes_count
      bonus_points = calculate_bonus_score(reply.body)
      spaminess_rating = calculate_spaminess(reply)
      (rep_points + bonus_points - spaminess_rating).to_i
    end

    def calculate_bonus_score(body)
      return 0 if body.blank?
      size_bonus = body.size > 200 ? 2 : 0
      code_bonus = body.include?("```") ? 1 : 0
      size_bonus + code_bonus
    end

    def calculate_spaminess(target)
      user = target.user
      return 100 unless user
      return 100 if user.blocked? || user.deleted?
      return 0 if user.trust?

      user_created_at = user.created_at || Time.now
      base_spaminess = 0
      base_spaminess += 25 if user_created_at >= 3.days.ago
      base_spaminess += 25 if user_created_at >= 7.days.ago
      base_spaminess
    end
  end
end
