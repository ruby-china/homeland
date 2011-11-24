# coding: utf-8
class PostsController < ApplicationController
  before_filter :require_user, :only => [:new, :edit, :create, :update, :destroy]
  def index
    scoped_posts = Post.normal
    if !params[:tag].blank?
      scoped_posts = scoped_posts.by_tag(params[:tag])
    end
    @posts = scoped_posts.recent.paginate :page => params[:page], :per_page => 20
    set_seo_meta("文章")
    
    drop_breadcrumb("文章")
    if params[:tag]
      drop_breadcrumb(params[:tag])
    else
      drop_breadcrumb("最新发布的文章")
    end
  end

  def show
    @post = Post.find(params[:id])
    @post.hits.incr
    set_seo_meta("#{@post.title}")
    drop_breadcrumb("文章")
    drop_breadcrumb("阅读")
  end

  def new
    @post = Post.new
  end

  def edit
    @post = Post.find(params[:id])
    @post.tag_list = @post.tags.join(", ")
    drop_breadcrumb("文章")
    drop_breadcrumb("编辑页面")
  end

  def create
    @post = Post.new(params[:post])
    @post.user_id = current_user.id
    
    if @post.save
      redirect_to @post, notice: '投稿成功，需等待审核通过以后才能显示到文章列表。'
    else
      render action: "new"
    end
  end

  def update
    @post = current_user.posts.find(params[:id])
    
    if @post.update_attributes(params[:post])
      redirect_to @post, notice: '文章更新成功。'
    else
      render action: "edit"
    end
  end
end
