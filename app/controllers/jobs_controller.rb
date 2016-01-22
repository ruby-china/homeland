class JobsController < ApplicationController
  helper_method :feed_node_topics_url

  def feed_node_topics_url
    # super.feed_node_topics_url(id: 25)
  end

  def index
    @node = Node.find(Node.jobs_id)
    @suggest_topics = Topic.where(node_id: @node.id).suggest.limit(3)
    suggest_topic_ids = @suggest_topics.map(&:id)
    @topics = @node.topics.last_actived.fields_for_list
    @topics = @topics.where.not(id: suggest_topic_ids) if suggest_topic_ids.count > 0
    @topics = @topics.includes(:user).paginate(page: params[:page], per_page: 15)
    set_seo_meta("#{@node.name} &raquo; #{t('menu.topics')}", "#{Setting.app_name}#{t('menu.topics')}#{@node.name}", @node.summary)
    render '/topics/index'
  end
end
