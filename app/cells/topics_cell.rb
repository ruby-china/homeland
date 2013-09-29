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

  # 置顶话题
  cache :sidebar_suggest_topics do |cell|
    CacheVersion.topic_last_suggested_at
  end
  def sidebar_suggest_topics
    @suggest_topics = Topic.suggest.limit(5)
    render
  end

  # 节点下面的最新话题
  cache :sidebar_for_node_recent_topics, :expires_in => 30.minutes do |cell, args|
    ['node',args[:topic].node_id].join("-")
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

  def tips
    @tip = ""
    if !SiteConfig.tips.blank?
      tips = SiteConfig.tips.split("\n")
      @tip = tips[rand(tips.count)]
    end
    render
  end
end
