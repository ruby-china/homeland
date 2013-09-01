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

  def topic_follow_tag(topic)
    return "" if current_user.blank?
    return "" if topic.blank?
    return "" if owner?(topic)
    class_name = "follow"
    if topic.follower_ids.include?(current_user.id)
      class_name = "followed"
    end
    icon = content_tag("i", "", :class => "icon small_#{class_name}")
    link_to raw([icon,"关注"].join(" ")), "#", :onclick => "return Topics.follow(this);",
                        'data-id' => topic.id,
                        'data-followed' => (class_name == "followed"),
                        :rel => "twipsy"
  end

  def topic_title_tag(topic)
    return t("topics.topic_was_deleted") if topic.blank?
    link_to(topic.title, topic_path(topic), :title => topic.title)
  end
  
  def topic_excellent_tag(topic)
    return "" if !topic.excellent?
    raw %(<i class="icon small_cert_on" title="精华贴"></i>)
  end

  def render_topic_last_reply_time(topic)
    l((topic.replied_at || topic.created_at), :format => :short)
  end

  def render_topic_created_at(topic)
    timeago(topic.created_at, :class => "published")
  end

  def render_topic_last_be_replied_time(topic)
    timeago(topic.replied_at)
  end

  def render_topic_node_select_tag(topic)
    return if topic.blank?
    grouped_collection_select :topic, :node_id, Section.all,
                    :sorted_nodes, :name, :id, :name, {:value => topic.node_id,
                    :include_blank => true, :prompt => "选择节点"}, :style => "width:145px;"
  end
end
