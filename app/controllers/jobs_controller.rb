class JobsController < ApplicationController
  helper_method :feed_node_topics_url

  def feed_node_topics_url
    # super.feed_node_topics_url(id: 25)
  end

  def index
    @node = Node.job
    @suggest_topics = Topic.where(node_id: @node.id).suggest.limit(3)
    suggest_topic_ids = @suggest_topics.map(&:id)
    @topics = @node.topics.last_actived.fields_for_list
    @topics = @topics.where.not(id: suggest_topic_ids) if suggest_topic_ids.count > 0
    @topics = @topics.includes(:user).page(params[:page])
    @page_title = "#{t('menu.jobs')} - #{t('menu.topics')}"
    render '/topics/index' if stale?(etag: [@node, @suggest_topics, @topics], template: '/topics/index')
  end
end
