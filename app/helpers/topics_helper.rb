# coding: utf-8  
module TopicsHelper
  def format_topic_body(text,title = "",allow_image = true)
    text.gsub!("\s","&nbsp;")
    text = simple_format(text)
    text.gsub!(/\[img\](http:\/\/.+?)\[\/img\]/i,'<img src="\1" alt="'+ h(title) +'" />')
    text.gsub!(/#([\d]+)楼&nbsp;/,raw('#<a href="#reply\1" class="at_floor" onclick="return hightlightReply(\1)">\1楼</a> '))
    text.gsub!(/@(.+?)&nbsp;/,raw('@<a href="/u/\1" class="at_user" title="\1">\1</a> '))
    text = auto_link(text,:all, :target => '_blank', :rel => "nofollow")
    return raw(text)
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
