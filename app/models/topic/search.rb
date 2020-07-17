class Topic
  module Search
    extend ActiveSupport::Concern

    def indexed_changed?
      saved_change_to_title? || saved_change_to_body?
    end

    def as_indexed_json
      {
        title: self.title,
        body: Homeland::Html.plain(self.body_html),
      }.as_json
    end
  end
end
