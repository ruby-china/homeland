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
  end
end
