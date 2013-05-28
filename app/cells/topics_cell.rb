# coding: utf-8
class TopicsCell < BaseCell

  helper :nodes

  # 首页节点目录
  cache :index_sections do |cell|
    CacheVersion.section_node_updated_at
  end
  def index_sections
    @sections = Section.all #.includes(:nodes)
    render
  end

  # 边栏的统计信息
  cache :sidebar_statistics, :expires_in => 30.minutes
  def sidebar_statistics
    @users_count = User.unscoped.count
    @topics_count = Topic.unscoped.count
    @replies_count = Reply.unscoped.count
    render
  end

  # 热门节点
  cache :sidebar_hot_nodes, :expires_in => 1.days
  def sidebar_hot_nodes
    @hot_nodes = Node.hots.limit(10)
    render
  end

  # 置顶话题
  cache :sidebar_suggest_topics do |cell|
    CacheVersion.topic_last_suggested_at
  end
  def sidebar_suggest_topics
    @suggest_topics = Topic.suggest.limit(5)
    render
  end

  # 节点下面的最新话题
  cache :sidebar_for_node_recent_topics, :expires_in => 20.minutes do |cell, args|
    args[:topic].id
  end
  def sidebar_for_node_recent_topics(args = {})
    topic = args[:topic]
    limit = topic.replies_count > 20 ? 20 : topic.replies_count
    limit = 1 if limit == 0
    @topics = topic.node.topics.recent.not_in(id: [topic.id]).limit(limit)
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

  def tips
    @tip = ""
    if !SiteConfig.tips.blank?
      tips = SiteConfig.tips.split("\n")
      @tip = tips[rand(tips.count)]
    end
    render
  end
end
