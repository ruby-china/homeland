# coding: utf-8  
module TopicsHelper
  def format_topic_body(text, options = {})
    text.gsub!(/\[img\](http:\/\/.+?)\[\/img\]/i,'<img src="\1" alt="'+ h(options[:title]) +'" />') if options[:allow_image]
    options[:title] ||= ''
    options[:allow_image] ||= true
    options[:mentioned_user_logins] ||= []

    # mention floor by #
    link_mention_floor!(text)

    # mention user by @
    link_mention_user!(text, options[:mentioned_user_logins])

    return raw(markdown(text))
  end

  # XXX: must be mentioned by #12楼
  # couldn't it be #12F ?
  def link_mention_floor!(text)
    text.gsub!(/#([\d]+)楼\s/,' #<a href="#reply\1" class="at_floor" data-floor="\1" onclick="return Topics.hightlightReply(\1)">\1楼</a> ')
  end

  def link_mention_user!(text, mentioned_user_logins)
    return text if mentioned_user_logins.blank?
    text.gsub!(/@(#{mentioned_user_logins.join('|')})/,'@<a href="/users/\1" class="at_user" title="\1">\1</a>')
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
