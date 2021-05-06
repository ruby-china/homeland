# frozen_string_literal: true

# 转换 body -> html
# [Plugin API]
module MarkdownBody
  extend ActiveSupport::Concern
  include ActionView::Helpers::OutputSafetyHelper
  include ActionView::Helpers::TextHelper
  include ApplicationHelper

  def body_html
    markdown(body)
  end

  def description
    @description = Rails.cache.fetch([self, "description"]) do
      text = Homeland::Html.plain(body_html)
      truncate(text, length: 120)
    end
  end
end
