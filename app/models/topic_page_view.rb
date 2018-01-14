# encoding: utf-8

require 'elasticsearch/persistence/model'

class TopicPageView
  include Elasticsearch::Persistence::Model

  attribute :topic_id,   Integer
  attribute :created_at, Time, default: ->(o, a) { Time.now }
  attribute :updated_at, Time, default: ->(o, a) { Time.now }

  validates :topic_id, :created_at, presence: true

  create_index!

  class << self
    def fake_pv
      data = self.new(
        topic_id:   rand(3_000),
        created_at: Time.at(Time.now.to_i - rand(1.month.to_i))
      ).as_json

      data.delete(:id)
      data
    end

    def fake_data
      Elasticsearch::Persistence.client.bulk(
        index: 'topic_page_views',
        type:  'topic_page_view',
        body:  (1..10_000).map { { index: { data: fake_pv } } },
        refresh: true
      )
    end
  end
end
