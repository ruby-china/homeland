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
      self.body_html = sanitize_markdown(Homeland::Markdown.call(body))
    end
  end
end
