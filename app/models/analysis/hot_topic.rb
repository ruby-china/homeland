# encoding: utf-8

module Analysis
  class HotTopic
    include Singleton

    HOT_TOPIC_SEARCH_SIZE = 700 # 聚合热门话题搜索数量
    HOT_TOPIC_SIZE = 100        # 热门话题数量
    WEEK_DAY_NUM = 7

    def week_hot_topic
      hot_topic = {}
      week_search_result.each_with_index do |result, index|
        result.each do |topic_id, pv|
          hot_topic[topic_id] ||= 0
          hot_topic[topic_id] += pv * (WEEK_DAY_NUM - index)
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
    def week_search_result
      result = TopicPageView.search(week_search_query)
      result = result.response.aggregations.deep_symbolize_keys
      result[:by_day][:buckets].map do |bucket|
        bucket[:topic_ids][:buckets].reduce({}) do |result, tb|
          result[tb[:key]] = tb[:doc_count]
          result
        end
      end
    end

    def week_search_query
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

  end
end
