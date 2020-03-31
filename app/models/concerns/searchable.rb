# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  included do
    after_commit on: :create do
      SearchIndexer.perform_later("index", self.class.name, self.id)
    end

    after_update do
      need_update = false
      if self.respond_to?(:indexed_changed?)
        need_update = indexed_changed?
      end

      SearchIndexer.perform_later("index", self.class.name, self.id) if need_update
    end

    after_commit on: :destroy do
      SearchIndexer.perform_later("delete", self.class.name, self.id)
    end
  end

  def reindex
    SearchIndexer.perform_later("index", self.class.name, self.id)
  end

  class_methods do
    def __meilisearch_index
      return @__meilisearch_index  if defined? @__meilisearch_index
      index = $meilisearch.index(self.name.tableize)
      index.show
      @__meilisearch_index = index
      @__meilisearch_index
    rescue MeiliSearch::HTTPError => e
      if e.message.include?("Not found - Index")
        @__meilisearch_index = $meilisearch.create_index(self.name.tableize)
        @__meilisearch_index
      else
        raise e
      end
    end
  end
end
