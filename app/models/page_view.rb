# encoding: utf-8

require 'elasticsearch/persistence/model'

class PageView
  include Elasticsearch::Persistence::Model

  attribute :target_id,   Integer, mapping: { type: 'integer' }
  attribute :target_type, String,  mapping: { type: 'text' }
  attribute :timestamp,   Integer, mapping: { type: 'long' }, default: -> { Time.now.to_i }

  validates :target_id, :target_type, presence: true

  create_index!
end
