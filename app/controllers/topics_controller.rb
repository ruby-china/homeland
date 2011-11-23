# coding: utf-8  
class TopicsController < ApplicationController
  before_filter :require_user, :only => [:new,:edit,:create,:update,:destroy,:reply]
  caches_page :feed, :expires_in => 1.hours

  public
  # GET /topics
  # GET /topics.xml
  def index
    @topics = Topic.last_actived.limit(15)
    set_seo_meta("","#{Setting.app_name}社区")
    render :stream => true
  end
  
  def feed
    @topics = Topic.recent.limit(20)
    response.headers['Content-Type'] = 'application/rss+xml'
    render :layout => false
  end

  def node
    @node = Node.find(params[:id])
    @topics = @node.topics.last_actived.paginate(:page => params[:page],:per_page => 50)
    set_seo_meta("#{@node.name} &raquo; 社区","#{Setting.app_name}社区#{@node.name}",@node.summary)
    render :action => "index", :stream => true
  end

  def recent
    @topics = Topic.recent.paginate(:page => params[:page], :per_page => 50)
    set_seo_meta("最近活跃的50个帖子 &raquo; 社区")
    render :action => "index", :stream => true
  end

  def search
    result = Redis::Search.query("Topic", params[:key], :limit => 500)
    ids = result.collect { |r| r["id"] }
    @topics = Topic.find(ids).paginate(:page => params[:page], :per_page => 20)
    set_seo_meta("搜索#{params[:s]} &raquo; 社区")
    render :action => "index", :stream => true
  end

  def show
    @topic = Topic.find(params[:id])
    @topic.hits.incr(1)
    @node = @topic.node
    @replies = @topic.replies.asc(:_id).all.cache
    if current_user
      @topic.user_readed(current_user.id)
      current_user.notifications.where(:reply_id.in => @replies.map(&:id), :read => false).update_all(:read => true)
    end
    set_seo_meta("#{@topic.title} &raquo; 社区")
    render :stream => true
  end

  # GET /topics/new
  # GET /topics/new.xml
  def new
    @topic = Topic.new
    if !params[:node].blank?
      @topic.node_id = params[:node]
      @node = Node.find_by_id(params[:node])
      if @node.blank?
        render_404
      end
    end
    set_seo_meta("发帖子 &raquo; 社区")
  end

  def reply
    @topic = Topic.find(params[:id])
    @reply = @topic.replies.build(params[:reply])        
    @reply.user_id = current_user.id
    if @reply.save
      @topic.user_readed(current_user.id)
      @msg = "回复成功。"
    else
      @msg = @reply.errors.full_messages.join("<br />")
    end
  end

  # GET /topics/1/edit
  def edit
    @topic = current_user.topics.find(params[:id])
    @node = @topic.node
    set_seo_meta("改帖子 &raquo; 社区")
  end

  # POST /topics
  # POST /topics.xml
  def create
    pt = params[:topic]
    @topic = Topic.new(pt)
    @topic.user_id = current_user.id
    @topic.node_id = params[:node] || pt[:node_id]

    if @topic.save
      redirect_to(topic_path(@topic.id), :notice => '帖子创建成功.')
    else
      render :action => "new"
    end
  end

  # PUT /topics/1
  # PUT /topics/1.xml
  def update
    @topic = current_user.topics.find(params[:id])
    pt = params[:topic]
    @topic.node_id = pt[:node_id]
    @topic.title = pt[:title]
    @topic.body = pt[:body]

    if @topic.save
      redirect_to(topic_path(@topic.id), :notice => '帖子修改成功.')
    else
      render :action => "edit"
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.xml
  def destroy
    @topic = current_user.topics.find(params[:id])
    @topic.destroy
    redirect_to(topics_path, :notice => '帖子删除成功.')
  end
end
