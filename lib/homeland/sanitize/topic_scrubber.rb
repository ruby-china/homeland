# frozen_string_literal: true

module Homeland
  module Sanitize
    class TopicScrubber < Rails::Html::PermitScrubber
      def initialize
        super

        self.tags = %w[
          p br img h1 h2 h3 h4 h5 h6 blockquote pre code b i del
          strong em table tr td tbody th strike del u a ul ol li span hr
          sub sup
        ]

        self.attributes = %w[
          class id lang style title href rel data-floor target
          alt src width height
          allowfullscreen class frameborder height src width
        ]
      end

      protected

      def allowed_node?(node)
        allowed = super
        return true if allowed

        case node.name
        when "iframe"
          return allowed_iframe?(node)
        end

        false
      end

      def allowed_iframe?(node)
        # Verify that the video URL is actually a valid YouTube video URL.
        valid = false
        attributes = node.attributes

        src = attributes["src"]&.value

        return false if src.blank?

        # Youtube
        if src.match?(%r{\A(?:https?:)?//(?:www\.)?youtube(?:-nocookie)?\.com/embed/})
          valid = true
        end

        # Vimeo
        if src.start_with?("https://player.vimeo.com/video/")
          valid = true
        end

        # Youku
        if src.match?(%r{\A(?:https{0,1}?:)?//player\.youku\.com/embed/})
          valid = true
        end

        # Bilibili
        if src.match?(%r{\A(?:https{0,1}?:)?//player\.bilibili\.com/player\.html})
          valid = true
        end

        valid
      end
    end
  end
end
