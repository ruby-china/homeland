# encoding: utf-8

require 'elasticsearch/persistence/model'

class TopicPageView
  include Elasticsearch::Persistence::Model

  attribute :topic_id, Integer

  validates :topic_id, :created_at, presence: true

  create_index!
end
