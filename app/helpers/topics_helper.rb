# coding: utf-8  
require 'rdiscount'
module TopicsHelper
  def format_topic_body(text, options = {})
    options[:title] = ''
    options[:allow_image] = true
    mentioned_user_logins = options[:mentioned_user_logins] || []
    text = h(text)
    text.gsub!( /\r\n?/, "\n" )
    text.gsub!( /\n/, "<br>" )
    text.gsub!(/```(<br>{0,}|\s{0,})(.+?)```(<br>{0,}|\s{0,})/im,'<pre><code>\2</code></pre>')
    text.gsub!(/\[img\](http:\/\/.+?)\[\/img\]/i,'<img src="\1" alt="'+ h(options[:title]) +'" />') if options[:allow_image]
    text = auto_link(text,:all, :target => '_blank', :rel => "nofollow")
    text.gsub!(/#([\d]+)楼\s/,'#<a href="#reply\1" class="at_floor" data-floor="\1" onclick="return Topics.hightlightReply(\1)">\1楼</a> ')
    link_mention_user!(text, mentioned_user_logins)
    return sanitize(text)
  end

  def link_mention_user!(text, mentioned_user_logins)
    return text if mentioned_user_logins.blank?
    text.gsub!(/@(#{mentioned_user_logins.join('|')})/,'@<a href="/users/\1" class="at_user" title="\1">\1</a>')
  end
  
  def topic_use_readed_text(state)
    case state
    when 0
      "在你读过以后还没有新变化"
    else
      "有新内容"
    end
  end
end
