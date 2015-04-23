# coding: utf-8
module Mongoid
  module MarkdownBody
    extend ActiveSupport::Concern
    include ActionView::Helpers::SanitizeHelper
    include ApplicationHelper

    included do
      before_save :markdown_body
      scope :without_body, -> { without(:body) }
    end

    private

    def markdown_body
      if self.body_changed?
        self.body_html = sanitize_markdown(MarkdownTopicConverter.format(self.body))
      end
    end
  end
end
