# frozen_string_literal: true

class Topic
  module Search
    extend ActiveSupport::Concern

    def as_indexed_json(_options = {})
      {
        id: self.id,
        title: self.title,
        body: self.full_body,
        created_at: self.created_at,
        updated_at: self.updated_at,
      }
    end

    def indexed_changed?
      saved_change_to_title? || saved_change_to_body?
    end

    def related_topics(limit: 5)
      opts = {
        query: {
          more_like_this: {
            fields: %i[title body],
            like: [
              {
                _index: self.class.index_name,
                _type: self.class.document_type,
                _id: id
              }
            ],
            min_term_freq: 2,
            min_doc_freq: 5
          }
        },
        size: limit
      }
      self.class.__elasticsearch__.search(opts).records.to_a
    rescue => e
      []
    end
  end
end
