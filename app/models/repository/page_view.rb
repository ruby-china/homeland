# encoding: utf-8

class Repository::PageView
  include Singleton
  include Elasticsearch::Persistence::Repository

  client Elasticsearch::Model.client

  index :page_views
  type :page_view

  mapping do
    indexes :target_id, type: 'integer'
    indexes :timestamp, type: 'date'
  end

  create_index!
end
