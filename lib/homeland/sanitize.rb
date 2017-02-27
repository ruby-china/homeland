module Homeland
  # Sanitize
  # Test case in: spec/helpers/application_helper_spec.rb
  module Sanitize
    # https://github.com/rgrove/sanitize#example-transformer-to-whitelist-youtube-video-embeds
    EMBED_VIDEO_TRANSFORMER = lambda do |env|
      node      = env[:node]
      node_name = env[:node_name]

      # Don't continue if this node is already whitelisted or is not an element.
      return if env[:is_whitelisted] || !node.element?

      # Don't continue unless the node is an iframe.
      return unless node_name == 'iframe'

      # Verify that the video URL is actually a valid YouTube video URL.
      valid_video_url = false

      # Youtube
      if node['src'].match?(%r{\A(?:https?:)?//(?:www\.)?youtube(?:-nocookie)?\.com/embed/})
        valid_video_url = true
      end

      # Youku
      if node['src'].match?(%r{\A(?:http[s]{0,1}?:)?//player\.youku\.com/embed/})
        valid_video_url = true
      end

      return unless valid_video_url

      # We're now certain that this is a YouTube embed, but we still need to run
      # it through a special Sanitize step to ensure that no unwanted elements or
      # attributes that don't belong in a YouTube embed can sneak in.
      ::Sanitize.node!(node, elements: %w(iframe),

                             attributes: {
                               'iframe' => %w(allowfullscreen class frameborder height src width)
                             })

      # Now that we're sure that this is a valid YouTube embed and that there are
      # no unwanted elements or attributes hidden inside it, we can tell Sanitize
      # to whitelist the current node.
      { node_whitelist: [node] }
    end

    DEFAULT = ::Sanitize::Config.freeze_config(
      elements: %w(
        p br img h1 h2 h3 h4 h5 h6 blockquote pre code b i del
        strong em table tr td tbody th strike del u a ul ol li span hr
      ),

      attributes: ::Sanitize::Config.merge({},
                                           # 这里要确保是 :all, 而不是 'all'
                                           :all  => %w(class id lang style tabindex title translate),
                                           'a'   => %w(href rel data-floor target),
                                           'img' => %w(alt src width height)),

      protocols: {
        'a' => { 'href' => ['http', 'https', 'mailto', :relative] }
      },

      transformers: [EMBED_VIDEO_TRANSFORMER]
    )
  end
end
