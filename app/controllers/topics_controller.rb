class TopicsController < ApplicationController
  load_and_authorize_resource only: [:new, :edit, :create, :update, :destroy,
                                     :favorite, :unfavorite, :follow, :unfollow, :suggest, :unsuggest, :ban]

  before_action :set_topic, only: [:ban, :edit, :update, :destroy, :follow,
                                   :unfollow, :suggest, :unsuggest, :close, :open]

  def index
    @suggest_topics = Topic.without_hide_nodes.suggest.fields_for_list.limit(3).to_a

    @topics = Topic.last_actived.without_suggest
    if current_user
      @topics = @topics.without_nodes(current_user.blocked_node_ids)
      @topics = @topics.without_users(current_user.blocked_user_ids)
    else
      @topics = @topics.without_hide_nodes
    end
    @topics = @topics.fields_for_list
    @topics = @topics.paginate(page: params[:page], per_page: 22, total_entries: 1500).to_a

    set_seo_meta t('menu.topics'), "#{Setting.app_name}#{t('menu.topics')}"
  end

  def feed
    @topics = Topic.without_hide_nodes.recent.without_body.limit(20).includes(:node, :user, :last_reply_user)
    render layout: false
  end

  def node
    @node = Node.find(params[:id])
    @topics = @node.topics.last_actived.fields_for_list
    @topics = @topics.includes(:user).paginate(page: params[:page], per_page: 25)
    title = @node.jobs? ? @node.name : "#{@node.name} &raquo; #{t('menu.topics')}"
    set_seo_meta title, "#{Setting.app_name}#{t('menu.topics')}#{@node.name}", @node.summary
    render action: 'index'
  end

  def node_feed
    @node = Node.find(params[:id])
    @topics = @node.topics.recent.without_body.limit(20)
    render layout: false
  end

  %w(no_reply popular).each do |name|
    define_method(name) do
      @topics = Topic.without_hide_nodes.send(name.to_sym).last_actived.fields_for_list.includes(:user)
      @topics = @topics.paginate(page: params[:page], per_page: 25, total_entries: 1500)

      set_seo_meta [t("topics.topic_list.#{name}"), t('menu.topics')].join(' &raquo; ')
      render action: 'index'
    end
  end

  def recent
    @topics = Topic.without_hide_nodes.recent.fields_for_list.includes(:user)
    @topics = @topics.paginate(page: params[:page], per_page: 25, total_entries: 1500)
    set_seo_meta [t('topics.topic_list.recent'), t('menu.topics')].join(' &raquo; ')
    render action: 'index'
  end

  def excellent
    @topics = Topic.excellent.recent.fields_for_list.includes(:user)
    @topics = @topics.paginate(page: params[:page], per_page: 25, total_entries: 1500)

    set_seo_meta [t('topics.topic_list.excellent'), t('menu.topics')].join(' &raquo; ')
    render action: 'index'
  end

  def show
    @topic = Topic.unscoped.includes(:user).find(params[:id])
    render_404 if @topic.deleted?

    @topic.hits.incr(1)
    @node = @topic.node

    @show_raw = params[:raw] == '1'

    @replies = Reply.unscoped.where(topic_id: @topic.id).without_body.order(:id).all

    check_current_user_liked_replies
    check_current_user_status_for_topic
    set_special_node_active_menu

    set_seo_meta "#{@topic.title} &raquo; #{t('menu.topics')}"
  end

  def check_current_user_liked_replies
    return false unless current_user

    # 找出用户 like 过的 Reply，给 JS 处理 like 功能的状态
    @user_liked_reply_ids = []
    @replies.each do |r|
      unless r.liked_user_ids.index(current_user.id).nil?
        @user_liked_reply_ids << r.id
      end
    end
  end

  def check_current_user_status_for_topic
    return false unless current_user
    # 通知处理
    current_user.read_topic(@topic, replies_ids: @replies.collect(&:id))
    # 是否关注过
    @has_followed = @topic.followed?(current_user.id)
    # 是否收藏
    @has_favorited = current_user.favorited_topic?(@topic.id)
  end

  def set_special_node_active_menu
    case @node.try(:id)
    when Node.jobs_id
      @current = ['/jobs']
    end
  end

  def new
    @topic = Topic.new(user_id: current_user.id)
    unless params[:node].blank?
      @topic.node_id = params[:node]
      @node = Node.find_by_id(params[:node])
      render_404 if @node.blank?
    end

    set_seo_meta "#{t('topics.post_topic')} &raquo; #{t('menu.topics')}"
  end

  def edit
    @node = @topic.node

    set_seo_meta "#{t('topics.edit_topic')} &raquo; #{t('menu.topics')}"
  end

  def create
    @topic = Topic.new(topic_params)
    @topic.user_id = current_user.id
    @topic.node_id = params[:node] || topic_params[:node_id]

    if @topic.save
      redirect_to(topic_path(@topic.id), notice: t('topics.create_topic_success'))
    else
      render action: 'new'
    end
  end

  def preview
    @body = params[:body]

    respond_to do |format|
      format.json
    end
  end

  def update
    @topic.admin_editing = true if current_user.admin?

    if can?(:change_node, @topic)
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
      redirect_to(topic_path(@topic.id), notice: t('topics.update_topic_success'))
    else
      render action: 'edit'
    end
  end

  def destroy
    @topic.destroy_by(current_user)
    redirect_to(topics_path, notice: t('topics.delete_topic_success'))
  end

  def favorite
    current_user.favorite_topic(params[:id])
    render plain: '1'
  end

  def unfavorite
    current_user.unfavorite_topic(params[:id])
    render plain: '1'
  end

  def follow
    @topic.push_follower(current_user.id)
    render plain: '1'
  end

  def unfollow
    @topic.pull_follower(current_user.id)
    render plain: '1'
  end

  def suggest
    @topic.update_attributes(excellent: 1)
    redirect_to @topic, notice: '加精成功。'
  end

  def unsuggest
    @topic.update_attribute(:excellent, 0)
    redirect_to @topic, notice: '加精已经取消。'
  end

  def ban
    @topic.ban!
    redirect_to @topic, notice: '已转移到 NoPoint 节点。'
  end

  def close
    @topic.close!
    redirect_to @topic, notice: '话题已关闭，将不再接受任何新的回复。'
  end

  def open
    @topic.open!
    redirect_to @topic, notice: '话题已重启开启。'
  end

  private

  def set_topic
    @topic ||= Topic.find(params[:id])
  end

  def topic_params
    params.require(:topic).permit(:title, :body, :node_id)
  end
end
