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

    def destroy(topic_id)
      Elasticsearch::Persistence.client.delete_by_query(
        index: self.index_name,
        type:  self.document_type,
        body:  { query: { term: { topic_id: topic_id } } }
      )
    end
  end
end
