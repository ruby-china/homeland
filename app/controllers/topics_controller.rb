# coding: utf-8
class TopicsController < ApplicationController

  load_and_authorize_resource :only => [:new,:edit,:create,:update,:destroy,:favorite, :follow, :unfollow, :suggest, :unsuggest]

  before_filter :set_menu_active
  caches_action :feed, :node_feed, :expires_in => 1.hours
  before_filter :init_base_breadcrumb

  def index
    @topics = Topic.last_actived.without_hide_nodes.fields_for_list.includes(:user).paginate(:page => params[:page], :per_page => 15, :total_entries => 1500)
    set_seo_meta("","#{Setting.app_name}#{t("menu.topics")}")
    drop_breadcrumb(t("topics.topic_list.hot_topic"))
  end

  def feed
    @topics = Topic.recent.without_body.limit(20).includes(:node,:user, :last_reply_user)
    render :layout => false
  end

  def node
    @node = Node.find(params[:id])
    @topics = @node.topics.last_actived.fields_for_list.includes(:user).paginate(:page => params[:page],:per_page => 15)
    set_seo_meta("#{@node.name} &raquo; #{t("menu.topics")}","#{Setting.app_name}#{t("menu.topics")}#{@node.name}",@node.summary)
    drop_breadcrumb("#{@node.name}")
    render :action => "index"
  end

  def node_feed
    @node = Node.find(params[:id])
    @topics = @node.topics.recent.without_body.limit(20)
    render :layout => false
  end

  %w(no_reply popular).each do |name|
    define_method(name) do
      @topics = Topic.send(name.to_sym).last_actived.fields_for_list.includes(:user).paginate(:page => params[:page], :per_page => 15, :total_entries => 1500)
      drop_breadcrumb(t("topics.topic_list.#{name}"))
      set_seo_meta([t("topics.topic_list.#{name}"),t("menu.topics")].join(" &raquo; "))
      render :action => "index"
    end
  end

  def recent
    @topics = Topic.recent.fields_for_list.includes(:user).paginate(:page => params[:page], :per_page => 15, :total_entries => 1500)
    drop_breadcrumb(t("topics.topic_list.recent"))
    set_seo_meta([t("topics.topic_list.recent"),t("menu.topics")].join(" &raquo; "))
    render :action => "index"
  end

  def excellent
    @topics = Topic.excellent.recent.fields_for_list.includes(:user).paginate(page: params[:page], per_page: 15, total_entries: 500)
    drop_breadcrumb(t("topics.topic_list.excellent"))
    set_seo_meta([t("topics.topic_list.excellent"),t("menu.topics")].join(" &raquo; "))
    render :action => "index"
  end

  def show
    @topic = Topic.without_body.find(params[:id])
    @topic.hits.incr(1)
    @node = @topic.node
    @show_raw = params[:raw] == "1"

    @per_page = Reply.per_page
    # 默认最后一页
    params[:page] = @topic.last_page_with_per_page(@per_page) if params[:page].blank?
    @page = params[:page].to_i > 0 ? params[:page].to_i : 1

    @replies = @topic.replies.unscoped.without_body.asc(:_id).paginate(:page => params[:page], :per_page => @per_page)
    if current_user
      # 找出用户 like 过的 Reply，给 JS 处理 like 功能的状态
      @user_liked_reply_ids = []
      @replies.each { |r| @user_liked_reply_ids << r.id if r.liked_user_ids.include?(current_user.id) }
      # 通知处理
      current_user.read_topic(@topic)
      # 是否关注过
      @has_followed = @topic.follower_ids.include?(current_user.id)
      # 是否收藏
      @has_favorited = current_user.favorite_topic_ids.include?(@topic.id)
    end
    set_seo_meta("#{@topic.title} &raquo; #{t("menu.topics")}")
    drop_breadcrumb("#{@node.try(:name)}", node_topics_path(@node.try(:id)))
    drop_breadcrumb t("topics.read_topic")

    fresh_when(:etag => [@topic,@has_followed,@has_favorited,@replies,@node,@show_raw])
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
    @topic = Topic.new(topic_params)
    @topic.user_id = current_user.id
    @topic.node_id = params[:node] || topic_params[:node_id]

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
    if @topic.lock_node == false || current_user.admin?
      # 锁定接点的时候，只有管理员可以修改节点
      @topic.node_id = topic_params[:node_id]

      if current_user.admin? && @topic.node_id_changed?
        # 当管理员修改节点的时候，锁定节点
        @topic.lock_node = true
      end
    end
    @topic.title = topic_params[:title]
    @topic.body = topic_params[:body]

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

  def suggest
    @topic = Topic.find(params[:id])
    @topic.update_attributes(excellent: 1)
    redirect_to @topic, success: "加精成功。"
  end

  def unsuggest
    @topic = Topic.find(params[:id])
    @topic.update_attribute(:excellent,0)
    redirect_to @topic, success: "加精已经取消。"
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

  def topic_params
    params.require(:topic).permit(:title, :body, :node_id)
  end
end
