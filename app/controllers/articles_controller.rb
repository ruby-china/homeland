# frozen_string_literal: true


# 专栏文章称为 article ，model 层继续用 topic
class ArticlesController < TopicsController

  before_action :set_article, only: [:show, :ban, :append, :edit, :update, :destroy, :follow,
                                   :unfollow, :action, :down]

  def index
    @articles = Article.all
  end

  def show
    @user = @article.user
    @column = @article.column

    if @article.draft and @article.user_id != current_user&.id
      redirect_to(topics_path, notice: t("topics.cannot_read_others_drafts"))
    end
    @article.hits.incr(1)
    @node = @article.node
    @show_raw = params[:raw] == "1"
    @can_reply = can?(:create, Reply)

    if params[:order_by] == 'like'
      @replies = Reply.unscoped.where(topic_id: @article.id).order(likes_count: :desc).all
    elsif params[:order_by] == 'created_at'
      @replies = Reply.unscoped.where(topic_id: @article.id).order(created_at: :desc).all
    else
      @replies = Reply.unscoped.where(topic_id: @article.id).order(:id).all
    end
    @can_reply = can?(:create, Reply)

    # fixme: 为了兼容回复列表模板里引用 @topic 而加。后续需考虑重构。
    @topic = @article
  end

  def update
    @article.admin_editing = true if current_user.admin?

    if current_user.admin? && current_user.id != @article.user_id
      # 管理员且非本帖作者
      @article.modified_admin = current_user
    end

    @article.title = article_params[:title]
    @article.body = article_params[:body]
    @article.cannot_be_shared = article_params[:cannot_be_shared]
    @article.article_public = article_params[:article_public]
    if params[:commit] and params[:commit] == 'draft'
      @article.draft = true
    else
      @article.draft = false
    end
    @article.save
  end

  def destroy
    @article.destroy_by(current_user)
    # 返回地址改为文章所在专栏的首页
    redirect_to(column_path(@article.column), notice: t("topics.delete_article_success"))
  end

  def new
    column = Column.find(params[:column_id])
    if !column.active
      redirect_to(columns_user_path(current_user), notice: "专栏被屏蔽！")
    end
    @article = Article.new(user_id: current_user.id, column_id: params[:column_id])
  end

  def create
    @article = Article.new(article_params)
    @article.user_id = current_user.id
    @article.column_id = article_params[:column_id]
    # 固定给一个 node id 占位
    @article.node_id = Setting.article_node.to_s

    if params[:commit] and params[:commit] == 'draft'
      @article.draft = true
    else
      @article.draft = false
    end

    @article.save
  end

  protected

  def article_params
    params.require(:article).permit(:title, :body, :node_id, :column_id, :cannot_be_shared, :article_public)
  end

  def set_article
    @article ||= Article.find(params[:id])
  end
end

