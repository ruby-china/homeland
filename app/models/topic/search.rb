# frozen_string_literal: true

class Topic
  module Search
    extend ActiveSupport::Concern

    def private_org
      self&.team.private? if self.team
    end

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
