# encoding: utf-8

module Analysis
  class HotTopic

    def week_hot_topic(size = 100)
      result = TopicPageView.search({
        query: week_range,
        aggs: {
          by_day: {
            date_histogram: day_histogram,
            aggs: {
              topic_ids: {
                terms: topic_id_terms(size)
              }
            }
          }
        }
      })

      result.response.aggregations.by_day.buckets.as_json
    end

    def week_range
      {
        range: {
          created_at: {
            gte: "now-7d/d",
            lte: "now/d"
          }
        }
      }
    end

    def day_histogram
      {
        field: "created_at",
        interval: "day",
        format: "yyyy-MM-dd",
        min_doc_count: 0,
        order: {
          _key: 'desc'
        }
      }
    end

    def topic_id_terms(size = 100)
      {
        field: "topic_id",
        size: size,
        order: {
          _count: 'desc'
        }
      }
    end

  end
end
