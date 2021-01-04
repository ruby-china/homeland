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
  HTML::Pipeline::AutoCorrectFilter,
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

      def example(locale)
        open(Rails.root.join("lib/homeland/markdown/guides.#{locale}.md")).read
      end
    end
  end
end
