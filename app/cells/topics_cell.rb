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
  
  def sidebar_for_new_topic_node(args)
    @node = args[:node]
    @action = args[:action]
    render 
  end
  
  def reply_help_block
    render
  end
end
