class SearchIndexer < ApplicationJob
  queue_as :search_indexer

  def perform(operation, type, id)
    obj = nil
    case type
    when 'topic'
      obj = Topic.find(id)
    when 'page'
      obj = Page.find(id)
    when 'user'
      obj = User.find(id)
    end

    if operation == 'update'
      obj.__elasticsearch__.update_document if obj
    elsif operation == 'delete'
      obj.__elasticsearch__.delete_document if obj
    end
  end
end
