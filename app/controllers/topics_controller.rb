# coding: utf-8
class TopicsController < ApplicationController

  load_and_authorize_resource :only => [:new,:edit,:create,:update,:destroy,:favorite, :follow, :unfollow]

  before_filter :set_menu_active
  caches_page :feed, :node_feed, :expires_in => 1.hours
  before_filter :init_base_breadcrumb

  def index
    @topics = Topic.last_actived.without_hide_nodes.fields_for_list.includes(:user).paginate(:page => params[:page], :per_page => 15, :total_entries => 1500)
    set_seo_meta("","#{Setting.app_name}#{t("menu.topics")}")
    drop_breadcrumb(t("topics.hot_topic"))
    #render :stream => true
  end

  def feed
    @topics = Topic.recent.without_body.limit(20).includes(:node,:user, :last_reply_user)
    response.headers['Content-Type'] = 'application/rss+xml; charset=utf-8'
    render :layout => false
  end

  def node
    @node = Node.find(params[:id])
    @topics = @node.topics.last_actived.fields_for_list.includes(:user).paginate(:page => params[:page],:per_page => 15)
    set_seo_meta("#{@node.name} &raquo; #{t("menu.topics")}","#{Setting.app_name}#{t("menu.topics")}#{@node.name}",@node.summary)
    drop_breadcrumb("#{@node.name}")
    render :action => "index" #, :stream => true
  end

  def node_feed
    @node = Node.find(params[:id])
    @topics = @node.topics.recent.without_body.limit(20)
    response.headers["Content-Type"] = "application/rss+xml"
    render :layout => false
  end

  def recent
    # TODO: 需要 includes :node,:user, :last_reply_user,但目前用了 paginate 似乎会使得 includes 没有效果
    @topics = Topic.recent.fields_for_list.includes(:user).paginate(:page => params[:page], :per_page => 15, :total_entries => 1500)
    drop_breadcrumb(t("topics.topic_list"))
    render :action => "index" #, :stream => true
  end

  def no_reply
    @topics = Topic.no_reply.recent.fields_for_list.includes(:user).paginate(:page => params[:page], :per_page => 15)
    render :action => "index" #, :stream => true
  end

  def show
    @topic = Topic.without_body.includes(:user, :node).find(params[:id])
    @topic.hits.incr(1)
    @node = @topic.node
    @replies = @topic.replies.without_body.asc(:_id).all.includes(:user).reject { |r| r.user.blank? }
    if current_user
      unless current_user.topic_read?(@topic)
        current_user.notifications.unread.any_of({:mentionable_type => 'Topic', :mentionable_id => @topic.id},
                                                 {:mentionable_type => 'Reply', :mentionable_id.in => @replies.map(&:id)},
                                                 {:reply_id.in => @replies.map(&:id)}).update_all(:read => true)
        current_user.read_topic(@topic)
      end
    end
    set_seo_meta("#{@topic.title} &raquo; #{t("menu.topics")}")
    drop_breadcrumb("#{@node.try(:name)}", node_topics_path(@node.try(:id)))
    drop_breadcrumb t("topics.read_topic")
   # render :stream => true
  end

  def new
    @topic = Topic.new
    if !params[:node].blank?
      @topic.node_id = params[:node]
      @node = Node.find_by_id(params[:node])
      if @node.blank?
        render_404
      end
      drop_breadcrumb("#{@node.name}", node_topics_path(@node.id))
    end
    drop_breadcrumb t("topics.post_topic")
    set_seo_meta("#{t("topics.post_topic")} &raquo; #{t("menu.topics")}")
  end

  def edit
    @topic = Topic.find(params[:id])
    @node = @topic.node
    drop_breadcrumb("#{@node.name}", node_topics_path(@node.id))
    drop_breadcrumb t("topics.edit_topic")
    set_seo_meta("#{t("topics.edit_topic")} &raquo; #{t("menu.topics")}")
  end

  def create
    pt = params[:topic]
    @topic = Topic.new(pt)
    @topic.user_id = current_user.id
    @topic.node_id = params[:node] || pt[:node_id]

    if @topic.save
      redirect_to(topic_path(@topic.id), :notice => t("topics.create_topic_success"))
    else
      render :action => "new"
    end
  end

  def preview
    @body = params[:body]

    respond_to do |format|
      format.json
    end
  end

  def update
    @topic = Topic.find(params[:id])
    pt = params[:topic]
    @topic.node_id = pt[:node_id]
    @topic.title = pt[:title]
    @topic.body = pt[:body]

    if @topic.save
      redirect_to(topic_path(@topic.id), :notice =>  t("topics.update_topic_success"))
    else
      render :action => "edit"
    end
  end

  def destroy
    @topic = Topic.find(params[:id])
    @topic.destroy_by(current_user)
    redirect_to(topics_path, :notice => t("topics.delete_topic_success"))
  end

  def favorite
    if params[:type] == "unfavorite"
      current_user.unfavorite_topic(params[:id])
    else
      current_user.favorite_topic(params[:id])
    end
    render :text => "1"
  end

  def follow
    @topic = Topic.find(params[:id])
    @topic.push_follower(current_user.id)
    render :text => "1"
  end

  def unfollow
    @topic = Topic.find(params[:id])
    @topic.pull_follower(current_user.id)
    render :text => "1"
  end

  protected

  def set_menu_active
    @current = @current = ['/topics']
  end

  def init_base_breadcrumb
    drop_breadcrumb(t("menu.topics"), topics_path)
  end

  private

  def init_list_sidebar
   if !fragment_exist? "topic/init_list_sidebar/hot_nodes"
      @hot_nodes = Node.hots.limit(10)
    end
    set_seo_meta(t("menu.topics"))
  end

end
