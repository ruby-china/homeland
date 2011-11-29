# coding: utf-8  
module TopicsHelper
  def format_topic_body(text, options = {})

    options[:title] ||= ''
    options[:allow_image] ||= true
    options[:mentioned_user_logins] ||= []
    options[:class] ||= ''

    text = h(text)
    
    # XXX don't use simple_format, it doesn't compatible with code_block
    text.gsub!( /\r\n?/, "\n" )
    text.gsub!( /\n/, "<br>" )
    
    ## fenced code block with ```
    parse_fenced_code_block!(text)
    
    # parse bbcode-style image [img]url[/img]
    parse_bbcode_image!(text, options[:title]) if options[:allow_image]
    
    # Auto Link
    
    text = auto_link(text,:all, :target => '_blank', :rel => "nofollow")
    
    # mention floor by #
    link_mention_floor!(text)
    
    # mention user by @
    link_mention_user!(text, options[:mentioned_user_logins])

    return raw(text)

  end

  def parse_fenced_code_block!(text)
    text.gsub!(/```(<br>{0,}|\s{0,})(.+?)```(<br>{0,}|\s{0,})/im,
                '<pre><code>\2</code></pre>')
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
