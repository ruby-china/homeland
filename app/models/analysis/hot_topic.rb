# encoding: utf-8

module Analysis
  class HotTopic
    include Singleton

    HOT_TOPIC_SEARCH_SIZE = 700 # 聚合热门话题搜索数量
    HOT_TOPIC_SIZE = 100        # 热门话题数量

    WEEK_DAY_NUM = 7
    DAY_HOUR_NUM = 24

    WEEKLY_CACHE_KEY = "hot_topic:weekly".freeze
    DAILY_CACHE_KEY  = "hot_topic:daily".freeze

    def weekly_hot_topic_ids
      Rails.cache.fetch(WEEKLY_CACHE_KEY) do
        calc_weekly_hot_topic_ids
      end
    end

    def daily_hot_topic_ids
      Rails.cache.fetch(DAILY_CACHE_KEY) do
        calc_daily_hot_topic_ids
      end
    end

    def calc_weekly_hot_topic_ids
      hot_topic = {}
      weekly_search_result.each_with_index do |result, index|
        result.each do |topic_id, pv|
          hot_topic[topic_id] ||= 0
          hot_topic[topic_id] += pv * (WEEK_DAY_NUM - index)
        end
      end
      hot_topic.sort_by { |_, v| -v }[0, HOT_TOPIC_SIZE].map { |r| r[0] }
    end

    def calc_daily_hot_topic_ids
      hot_topic = {}
      daily_search_result.each_with_index do |result, index|
        result.each do |topic_id, pv|
          hot_topic[topic_id] ||= 0
          hot_topic[topic_id] += pv * (DAY_HOUR_NUM - index)
        end
      end
      hot_topic.sort_by { |_, v| -v }[0, HOT_TOPIC_SIZE].map { |r| r[0] }
    end

    # 返回一个 size 为 7 的 Array
    # Array 第一个元素为当天热门话题所对应的 Hash, Hash 结构为 { topic_id1 => pv, topic_id1 => pv, ...}
    # Array 第二个元素为当天热门话题所对应的 Hash, 依次类推
    #
    # [
    #   { topic_id1 => pv, topic_id1 => pv, ...},
    #   ...
    #   { topic_id1 => pv, topic_id1 => pv, ...}
    # ]
    def weekly_search_result
      result = TopicPageView.search(weekly_search_query)
      result = result.response.aggregations.deep_symbolize_keys
      result[:by_day][:buckets].map do |bucket|
        bucket[:topic_ids][:buckets].reduce({}) do |result, tb|
          result[tb[:key]] = tb[:doc_count]
          result
        end
      end
    end

    def weekly_search_query
      {
        size: 0,
        query: {
          range: {
            created_at: {
              gt: "now-7d/d",
              lte: "now/d",
              time_zone: "+08:00"
            }
          }
        },
        aggs: {
          by_day: {
            date_histogram: {
              field: "created_at",
              interval: "day",
              format: "year_month_day",
              time_zone: "+08:00",
              min_doc_count: 0,
              order: {
                _key: "desc"
              }
            },
            aggs: {
              topic_ids: {
                terms: {
                  field: "topic_id",
                  size: HOT_TOPIC_SEARCH_SIZE,
                  order: {
                    _count: "desc"
                  }
                }
              }
            }
          }
        }
      }
    end

    # 返回一个 size 为 24 的 Array
    # Array 第一个元素为现在所在小时热门话题所对应的 Hash, Hash 结构为 { topic_id1 => pv, topic_id1 => pv, ...}
    # Array 第二个元素为上1个小时当天热门话题所对应的 Hash, 依次类推
    #
    # [
    #   { topic_id1 => pv, topic_id1 => pv, ...},
    #   ...
    #   { topic_id1 => pv, topic_id1 => pv, ...}
    # ]
    def daily_search_result
      result = TopicPageView.search(daily_search_query)
      result = result.response.aggregations.deep_symbolize_keys
      result[:by_hour][:buckets].map do |bucket|
        bucket[:topic_ids][:buckets].reduce({}) do |result, tb|
          result[tb[:key]] = tb[:doc_count]
          result
        end
      end
    end

    def daily_search_query
      {
        size: 0,
        query: {
          range: {
            created_at: {
              gte: "now-24h/h",
              lte: "now/h",
              time_zone: "+08:00"
            }
          }
        },
        aggs: {
          by_hour: {
            date_histogram: {
              field: "created_at",
              interval: "hour",
              format: "date_time_no_millis",
              time_zone: "+08:00",
              min_doc_count: 0,
              order: {
                _key: "desc"
              }
            },
            aggs: {
              topic_ids: {
                terms: {
                  field: "topic_id",
                  size: HOT_TOPIC_SEARCH_SIZE,
                  order: {
                    _count: "desc"
                  }
                }
              }
            }
          }
        }
      }
    end

  end
end
