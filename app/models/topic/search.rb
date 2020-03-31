# frozen_string_literal: true

class Topic
  module Search
    extend ActiveSupport::Concern

    included do
      mapping do
        indexes :title, term_vector: :yes
        indexes :body, term_vector: :yes
      end
    end

    def as_indexed_json(_options = {})
      {
        title: self.title,
        body: self.full_body
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
