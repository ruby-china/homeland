# encoding: utf-8

namespace :analysis do
  namespace :hot_topic do
    desc '二十四小时热门话题更新'
    task daily: :environment do
      daily_hot_topic_ids = Analysis::HotTopic.instance.calc_daily_hot_topic_ids
      Rails.cache.write(Analysis::HotTopic::DAILY_CACHE_KEY, daily_hot_topic_ids, expires_in: 10.minutes)
    end

    desc '一周热门话题更新'
    task weekly: :environment do
      weekly_hot_topic_ids = Analysis::HotTopic.instance.calc_weekly_hot_topic_ids
      Rails.cache.write(Analysis::HotTopic::WEEKLY_CACHE_KEY, weekly_hot_topic_ids, expires_in: 1.hour)
    end
  end
end
