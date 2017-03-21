require 'digest/md5'
module TopicsHelper
  def topic_favorite_tag(topic, opts = {})
    return '' if current_user.blank?
    opts[:class] ||= ''
    class_name = ''
    link_title = '收藏'
    if current_user && current_user.favorite_topic?(topic)
      class_name = 'active'
      link_title = '取消收藏'
    end

    icon = raw(content_tag('i', '', class: 'fa fa-bookmark'))
    if opts[:class].present?
      class_name += ' ' + opts[:class]
    end

    link_to(raw("#{icon} 收藏"), '#', title: link_title, class: "bookmark #{class_name}", 'data-id' => topic.id)
  end

  def topic_follow_tag(topic, opts = {})
    return '' if current_user.blank?
    return '' if topic.blank?
    return '' if owner?(topic)
    opts[:class] ||= ''
    class_name = 'follow'
    class_name += ' active' if current_user.follow_topic?(topic)
    if opts[:class].present?
      class_name += ' ' + opts[:class]
    end
    icon = content_tag('i', '', class: 'fa fa-eye')
    link_to(raw("#{icon} 关注"), '#', 'data-id' => topic.id, class: class_name)
  end

  def topic_title_tag(topic, opts = {})
    return t('topics.topic_was_deleted') if topic.blank?
    if opts[:reply]
      index = topic.floor_of_reply(opts[:reply])
      path = main_app.topic_path(topic, anchor: "reply#{index}")
    else
      path = main_app.topic_path(topic)
    end
    link_to(topic.title, path, title: topic.title)
  end

  def topic_excellent_tag(topic)
    return '' unless topic.excellent?
    content_tag(:i, '', title: '精华帖', class: 'fa fa-diamond', data: { toggle: 'tooltip' })
  end

  def topic_close_tag(topic)
    return '' unless topic.closed?
    content_tag(:i, '', title: '问题已解决／话题已结束讨论', class: 'fa fa-check', data: { toggle: 'tooltip' })
  end

  def render_node_name(name, id)
    link_to(name, node_topics_path(id), class: 'node')
  end
end
