# coding: utf-8  
class TopicsController < ApplicationController
  before_filter :require_user, :only => [:new,:edit,:create,:update,:destroy,:reply]
  before_filter :set_menu_active
  caches_page :feed, :expires_in => 1.hours
  before_filter :init_base_breadcrumb

  def index
    @topics = Topic.last_actived.limit(15).includes(:node,:user, :last_reply_user)
    set_seo_meta("","#{Setting.app_name}#{t("menu.topics")}")
    drop_breadcrumb(t("topics.hot_topic"))
    render :stream => true
  end
  
  def feed
    @topics = Topic.recent.limit(20).includes(:node,:user, :last_reply_user)
    response.headers['Content-Type'] = 'application/rss+xml'
    render :layout => false
  end

  def node
    @node = Node.find(params[:id])
    @topics = @node.topics.last_actived.paginate(:page => params[:page],:per_page => 50)
    set_seo_meta("#{@node.name} &raquo; #{t("menu.topics")}","#{Setting.app_name}#{t("menu.topics")}#{@node.name}",@node.summary)
    drop_breadcrumb("#{@node.name}")
    render :action => "index", :stream => true
  end

  def recent
    # TODO: 需要 includes :node,:user, :last_reply_user,但目前用了 paginate 似乎会使得 includes 没有效果
    @topics = Topic.recent.paginate(:page => params[:page], :per_page => 50)
    drop_breadcrumb(t("topics.topic_list"))
    render :action => "index", :stream => true
  end

  def search
    result = Redis::Search.query("Topic", params[:key], :limit => 500)
    ids = result.collect { |r| r["id"] }
    @topics = Topic.where(:_id.in => ids).limit(50).includes(:node,:user, :last_reply_user)
    set_seo_meta("#{t("common.search")}#{params[:s]} &raquo; #{t("menu.topics")}")
    drop_breadcrumb("#{t("common.search")} #{params[:key]}")
    render :action => "index", :stream => true
  end

  def show
    @topic = Topic.find(params[:id])
    @topic.hits.incr(1)
    @node = @topic.node
    @replies = @topic.replies.asc(:_id).all.includes(:user).cache
    if current_user
      current_user.read_topic(@topic)
      current_user.notifications.where(:reply_id.in => @replies.map(&:id), :read => false).update_all(:read => true)
    end
    set_seo_meta("#{@topic.title} &raquo; #{t("menu.topics")}")
    drop_breadcrumb("#{@node.name}", node_topics_path(@node.id))
    drop_breadcrumb t("topics.read_topic")
    render :stream => true
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

  def reply
    @topic = Topic.find(params[:id])
    @reply = @topic.replies.build(params[:reply])        
    @reply.user_id = current_user.id
    if @reply.save
      current_user.read_topic(@topic)
      @msg = t("topics.reply_success")
    else
      @msg = @reply.errors.full_messages.join("<br />")
    end
  end


  def edit
    @topic = current_user.topics.find(params[:id])
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

  def update
    @topic = current_user.topics.find(params[:id])
    pt = params[:topic]
    @topic.node_id = pt[:node_id]
    @topic.title = pt[:title]
    @topic.body = pt[:body]

    if @topic.save
      redirect_to(topic_path(@topic.id), t("topics.edit_topic_success"))
    else
      render :action => "edit"
    end
  end

  def destroy
    @topic = current_user.topics.find(params[:id])
    @topic.destroy
    redirect_to(topics_path, :notice => t("topics.delete_topic_success"))
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
