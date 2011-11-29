# coding: utf-8  
module TopicsHelper
  def format_topic_body(text, options = {})

    options[:title] ||= ''
    options[:allow_image] ||= true
    options[:mentioned_user_logins] ||= []
    options[:class] ||= ''

    text = h(text)
    
    ## fenced code block with ```
    text = parse_fenced_code_block(text)
    
    # parse bbcode-style image [img]url[/img]
    parse_bbcode_image!(text, options[:title]) if options[:allow_image]
    
    # Auto Link
    
    text = auto_link(text,:all, :target => '_blank', :rel => "nofollow")
    
    # mention floor by #
    link_mention_floor!(text)
    
    # mention user by @
    link_mention_user!(text, options[:mentioned_user_logins])

    text = simple_format(text)

    text = reformat_code_block(text) do |code|
      code.gsub!(/<br\s?\/?>/, "")
    end

    return raw(text)

  end

  def parse_fenced_code_block(text)
    source = String.new(text.to_s)

    source.gsub!(/(```.+?```)/im) do
      code = CGI::unescapeHTML($1)

      # let the markdown compiler draw the <pre><code>
      # (with syntax highlighting)
      $markdown.render(code)
    end

    return source
  end

  def reformat_code_block(text, &block)
    # XXX: ActionView uses SafeBuffer, not String
    # and it's gsub is different from String#gsub
    # which makes gsub with block unusable.

    source = String.new(text.to_s)

    source.gsub!(/<pre>(.+?)<\/pre>/mi) do |matched|
      code = $1

      block.call(code)

      logger.debug("after: #{code}")

      "<pre>#{code}</pre>"
    end
    source
  end

  def parse_bbcode_image!(text, title)
    text.gsub!(/\[img\](http:\/\/.+?)\[\/img\]/i) do
      src = $1
      image_tag(src, :alt => title)
    end
  end

  def link_mention_floor!(text)

    # matches #X樓, #X楼, #XF, #Xf, with or without :
    # doesn't care if there is a space after the mention command
    expression = /#([\d]+)([楼樓Ff]\s?)/

    text.gsub!(expression) do |floor_token|
      floorish, postfix = $1, $2

      html_options = {
        :class => "at_floor", "data-floor" => floorish,
        :onclick => "return Topics.hightlightReply(#{floorish})"
      }

      link_to(floor_token, "#reply#{floorish}", html_options) 
    end
  end

  def link_mention_user!(text, mentioned_user_logins)
    return text if mentioned_user_logins.blank?
    text.gsub!(/@(#{mentioned_user_logins.join('|')})/) do |mention_token|
      user_name = $1
      link_to(mention_token, user_path(user_name), 
              :class => "at_user", :title => mention_token)
    end
  end
  
  def topic_use_readed_text(state)
    case state
    when true
      "在你读过以后还没有新变化"
    else
      "有新内容"
    end
  end

  def render_topic_title(topic)
    link_to(topic.title, topic_path(topic), :title => topic.title)
  end
  
  def render_topic_last_reply_time(topic)
    l((topic.replied_at || topic.created_at), :format => :short)
  end
  
  def render_topic_count(topic)
    topic.replies_count
  end
  
  def render_topic_created_at(topic)
    timeago(topic.created_at)
  end
  
  def render_topic_last_be_replied_time(topic)
    timeago(topic.replied_at)
  end
end
