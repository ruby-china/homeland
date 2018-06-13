# frozen_string_literal: true

require "html/pipeline"

context = {
  gfm: true,
  video_width: 700,
  video_height: 387
}

filters = [
  Homeland::Pipeline::NormalizeMentionFilter,
  Homeland::Pipeline::EmbedVideoFilter,
  Homeland::Pipeline::MarkdownFilter,
  Homeland::Pipeline::MentionFilter,
  Homeland::Pipeline::FloorFilter,
  Homeland::Pipeline::TwemojiFilter
]

TopicPipeline = HTML::Pipeline.new(filters, context)

module Homeland
  class Markdown
    class << self
      def call(body)
        result = TopicPipeline.call(body)[:output].inner_html
        result.strip!
        result
      end

      def example
        @example ||= open(Rails.root.join("lib/homeland/markdown_guides.md")).read
      end
    end
  end
end
