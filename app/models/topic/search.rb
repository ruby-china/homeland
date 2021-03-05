# frozen_string_literal: true

class Topic
  module Search
    extend ActiveSupport::Concern

    def indexed_changed?
      saved_change_to_title? || saved_change_to_body?
    end

    def as_indexed_json
      {
        title: title,
        body: Homeland::Html.plain(body_html)
      }.as_json
    end
  end
end
