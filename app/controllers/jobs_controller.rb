class JobsController < ApplicationController
  helper_method :feed_node_topics_url
  
  def feed_node_topics_url
    # super.feed_node_topics_url(id: 25)
  end
  
  def node_id
    25
  end
  
  def index
    @node = Node.find(node_id)
    @suggest_topics = Topic.where(node_id: node_id).suggest.limit(3)
    suggest_topic_ids = @suggest_topics.collect(&:id)
    @topics = @node.topics.last_actived.fields_for_list.where(:_id.nin => suggest_topic_ids).includes(:user).paginate(:page => params[:page],:per_page => 15)
    set_seo_meta("#{@node.name} &raquo; #{t("menu.topics")}","#{Setting.app_name}#{t("menu.topics")}#{@node.name}",@node.summary)
    drop_breadcrumb("#{@node.name}")
    render "/topics/index"
  end
end