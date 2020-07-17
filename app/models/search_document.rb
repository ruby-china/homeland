# frozen_string_literal: true

class SearchDocument < ActiveRecord::Base
  belongs_to :searchable, polymorphic: true

  def self.index(obj)
    return unless obj.respond_to? :search_document
    doc = obj.search_document
    if doc.nil?
      SearchDocument.create(searchable: obj)
      doc = obj.reload.search_document
    end

    indexed_json = obj.as_indexed_json
    tokens = Homeland::Search.prepare_data([indexed_json["title"], indexed_json["body"]].join(" "))
    SearchDocument.exec_sql("UPDATE search_documents SET
                             tokens = TO_TSVECTOR('simple', :tokens), content = :content
                             WHERE id = :id", tokens: tokens, content: indexed_json["body"], id: doc.id)
  end

  # Execute SQL manually
  def self.exec_sql(*args)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
    ActiveRecord::Base.connection.execute(sql)
  end

  def exec_sql(*args)
    ActiveRecord::Base.exec_sql(*args)
  end
end
