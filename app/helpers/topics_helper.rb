# coding: utf-8
require 'digest/md5'
module TopicsHelper
  def format_topic_body(text)
    MarkdownTopicConverter.format(text)
  end

  def topic_use_readed_text(state)
    case state
    when true
      t("topics.have_no_new_reply")
    else
      t("topics.has_new_replies")
    end
  end
  
  def topic_favorite_tag(topic)
    return "" if current_user.blank?
    class_name = "bookmark"
    link_title = "收藏"
    if current_user and current_user.favorite_topic_ids.include?(topic.id)
      class_name = "bookmarked"
      link_title = "取消收藏"
    end
    
    link_to "", "#", :onclick => "return Topics.favorite(this);", 'data-id' => topic.id, :class => "icon small_#{class_name}", :title => link_title, :rel => "twipsy"
  end

  def render_topic_title(topic)
    return t("topics.topic_was_deleted") if topic.blank?
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

  def render_topic_node_select_tag(topic)
    return if topic.blank?
    grouped_collection_select :topic, :node_id, Section.all, 
                    :sorted_nodes, :name, :id, :name, :value => topic.node_id,
                    :include_blank => true, :prompt => "选择节点"
  end
end
