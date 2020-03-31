# frozen_string_literal: true

class SearchIndexer < ApplicationJob
  queue_as :search_indexer

  def perform(operation, type, id)
    obj = nil

    case type.downcase
    when "topic"
      obj = Topic.find_by_id(id)
    when "page"
      obj = Page.find_by_id(id)
    when "user"
      obj = User.find_by_id(id)
    end

    return false unless obj

    index = obj.class.__meilisearch_index

    if operation == "update"
      index.add_documents(obj.as_indexed_json)
    elsif operation == "delete"
      index.delete_document(obj.id)
    elsif operation == "index"
      index.add_documents(obj.as_indexed_json)
    end
  rescue => e
    raise e unless Rails.env.test?
  end
end
