# coding: utf-8  
module TopicsHelper
  def format_topic_body(text,title = "",allow_image = true)
    text = simple_format(text)
    if allow_image
      text = text.gsub(/\[img\](http:\/\/.+?)\[\/img\]/,'<img src="\1" alt="'+ h(title) +'" />')
      # Youku
      text = text.gsub(/http:\/\/player\.youku\.com\/player\.php\/sid\/([\w]+)\/v\.swf/i,
        '<embed src="http://player.youku.com/player.php/sid/\1/v.swf" 
          quality="high" width="480" height="400" align="middle" 
          allowScriptAccess="sameDomain" type="application/x-shockwave-flash"></embed>')
      # Tudou
      text = text.gsub(/http:\/\/www\.tudou\.com\/[v|l]\/([\-\w]+)[\/v\.swf]{0,6}/i,
        '<embed src="http://www.tudou.com/v/\1/v.swf" 
        type="application/x-shockwave-flash" allowscriptaccess="always" 
        allowfullscreen="true" wmode="opaque" width="480" height="400"></embed>')
      # Ku6
      text = text.gsub(/http:\/\/player\.ku6\.com\/refer\/([\-_\w]+)\/v\.swf/i,
        '<embed src="http://player.ku6.com/refer/\1/v.swf" 
        type="application/x-shockwave-flash" allowscriptaccess="always" 
        allowfullscreen="true" wmode="opaque" width="480" height="400"></embed>')
    end
    text = auto_link(text,:all, :target => '_blank', :rel => "nofollow")
    text = text.gsub(/@([\d]+)楼\s/,'@<a href="#reply\1" onclick="return hightlightReply(\1)">\1楼</a> ')
    text = text.gsub("\s","&nbsp;")
    return text
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
