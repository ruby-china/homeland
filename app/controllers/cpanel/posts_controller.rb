# coding: utf-8  
class Cpanel::PostsController < Cpanel::ApplicationController
  def index
    @posts = Post.unscoped.desc(:_id).includes(:user).paginate :page => params[:page], :per_page => 30

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @posts }
    end
  end

  def show
    @post = Post.unscoped.find(params[:id])
    drop_breadcrumb("文章")
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.xml
  def new
    @post = Post.new
    drop_breadcrumb("文章")
    drop_breadcrumb("创建")
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @post = Post.unscoped.find(params[:id])
    @post.tag_list = @post.tags.join(", ")

  end

  # POST /posts
  # POST /posts.xml
  def create
    @post = Post.new(params[:post])

    respond_to do |format|
      if @post.save
        format.html { redirect_to(cpanel_posts_path, :notice => 'Post was successfully created.') }
        format.xml  { render :xml => @post, :status => :created, :location => @post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.xml
  def update
    @post = Post.unscoped.find(params[:id])
    @post.title = params[:post][:title]
    @post.body = params[:post][:body]
    @post.tag_list = params[:post][:tag_list]
    @post.user_id = params[:post][:user_id]
    @post.state = params[:post][:state]

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to(cpanel_posts_path, :notice => 'Post was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @post = Post.unscoped.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to(cpanel_posts_path) }
      format.xml  { head :ok }
    end
  end
end
