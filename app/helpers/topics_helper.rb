require 'digest/md5'
module TopicsHelper
  def markdown(text)
    sanitize_markdown(MarkdownTopicConverter.format(text))
  end

  def topic_use_readed_text(state)
    case state
    when true
      t('topics.have_no_new_reply')
    else
      t('topics.has_new_replies')
    end
  end

  def topic_favorite_tag(topic, opts = {})
    return '' if current_user.blank?
    opts[:class] ||= ''
    class_name = ''
    link_title = '收藏'
    if current_user && current_user.favorite_topic_ids.include?(topic.id)
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
    class_name += ' active' if topic.follower_ids.include?(current_user.id)
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
    content_tag(:i, '', title: '精华帖', class: 'fa fa-diamond')
  end

  def render_topic_last_reply_time(topic)
    l((topic.replied_at || topic.created_at), format: :short)
  end

  def render_topic_created_at(topic)
    timeago(topic.created_at, class: 'published')
  end

  def render_topic_last_be_replied_time(topic)
    timeago(topic.replied_at)
  end

  def render_topic_node_select_tag(topic)
    return if topic.blank?
    opts = {
      'data-width' => '140px',
      'data-live-search' => 'true',
      class: 'show-menu-arrow'
    }
    grouped_collection_select :topic, :node_id, Section.all, :sorted_nodes, :name, :id, :name,
                              { value: topic.node_id, prompt: '选择节点' }, opts
  end
end
