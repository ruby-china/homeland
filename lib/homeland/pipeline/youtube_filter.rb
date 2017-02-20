module Homeland
  class Pipeline
    class YoutubeFilter < HTML::Pipeline::TextFilter
      YOUTUBE_URL_REGEXP = %r{(\s|^|<div>|<br>)(https?://)(www.)?(youtube\.com/watch\?v=|youtu\.be/|youtube\.com/watch\?feature=player_embedded&v=)([A-Za-z0-9_-]*)(\&\S+)?(\?\S+)?}

      def call
        @text.gsub(YOUTUBE_URL_REGEXP) do
          youtube_id = Regexp.last_match(5)
          close_tag = Regexp.last_match(1) if ['<br>', '<div>'].include? Regexp.last_match(1)
          wmode = context[:video_wmode]
          autoplay = context[:video_autoplay] || false
          hide_related = context[:video_hide_related] || false
          src = "//www.youtube.com/embed/#{youtube_id}"
          params = []
          params << "wmode=#{wmode}" if wmode
          params << 'autoplay=1' if autoplay
          params << 'rel=0' if hide_related
          src += "?#{params.join '&'}" unless params.empty?

          %(#{close_tag}<span class="embed-responsive embed-responsive-16by9"><iframe class="embed-responsive-item" src="#{src}" allowfullscreen></iframe></span>)
        end
      end
    end
  end
end
