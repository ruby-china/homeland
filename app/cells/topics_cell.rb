# coding: utf-8
class TopicsCell < BaseCell

  helper :nodes

  # 首页节点目录
  cache :index_sections do |cell|
    "index_sections:#{CacheVersion.section_node_updated_at}"
  end
  def index_sections
    @sections = Section.all
    render
  end

  # 边栏的统计信息
  cache :sidebar_statistics, :expires_in => 30.minutes
  def sidebar_statistics
    render
  end

  # 热门节点
  cache :sidebar_hot_nodes, :expires_in => 30.minutes
  def sidebar_hot_nodes
    @hot_nodes = Node.hots.limit(30)
    render
  end

  # 置顶话题
  cache :sidebar_suggest_topics do |cell|
    "sidebar_suggest_topics:#{CacheVersion.topic_last_suggested_at}"
  end
  def sidebar_suggest_topics
    @suggest_topics = Topic.suggest.limit(5)
    render
  end

  def sidebar_for_new_topic_node(args = {})
    @node = args[:node]
    @action = args[:action]
    render
  end

  # 相关类似话题, 取相关词出现最少3次，相关度最高的3篇
  cache :sidebar_for_more_like_this, :expires_in => 1.day do |cell, args|
    args[:topic].id
  end
  def sidebar_for_more_like_this(args = {})
    @topics = args[:topic].more_like_this do
      minimum_term_frequency 5
      paginate :page => 1, :per_page => 10
    end.results
    render
  end

  def reply_help_block(opts = {})
    @full = opts[:full] || false
    render
  end

  cache :index_locations, :expires_in => 1.days
  def index_locations
    @hot_locations = Location.hot.limit(12)
    render
  end
  
  cache :high_likes_topics, :expires_in => 3.hours
  def high_likes_topics
    @topics = Topic.by_week.high_likes.limit(10)
    render
  end
  
  cache :high_replies_topics, :expires_in => 3.hours
  def high_replies_topics
    @topics = Topic.by_week.high_replies.limit(10)
    render
  end
end
