# frozen_string_literal: true

module Markdownable
  extend ActiveSupport::Concern
  include ActionView::Helpers::OutputSafetyHelper
  include ApplicationHelper

  def body_html
    markdown(body)
  end
end
