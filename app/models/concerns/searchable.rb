module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    after_commit on: :create do
      SearchIndexer.perform_later('index', self.class.name, self.id)
    end

    after_update do
      need_update = false
      if self.respond_to?(:indexed_changed?)
        need_update = indexed_changed?
      end

      SearchIndexer.perform_later('index', self.class.name, self.id) if need_update
    end

    after_commit on: :destroy do
      SearchIndexer.perform_later('delete', self.class.name, self.id)
    end
  end
end
