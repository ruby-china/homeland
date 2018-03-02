# frozen_string_literal: true

# 转换 body -> html
# [Plugin API]
module MarkdownBody
  extend ActiveSupport::Concern
  include ActionView::Helpers::OutputSafetyHelper
  include ApplicationHelper

  def body_html
    markdown(body)
  end
end
