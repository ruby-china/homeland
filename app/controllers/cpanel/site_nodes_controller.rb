# coding: UTF-8
class Cpanel::SiteNodesController < Cpanel::ApplicationController

  def index
    @site_nodes = SiteNode.desc('_id').paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @site_node = SiteNode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end

  def new
    @site_node = SiteNode.new

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end

  def edit
    @site_node = SiteNode.find(params[:id])
  end

  def create
    @site_node = SiteNode.new(params[:site_node].permit!)

    respond_to do |format|
      if @site_node.save
        format.html { redirect_to(cpanel_site_nodes_path, :notice => 'Site node 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end

  def update
    @site_node = SiteNode.find(params[:id])

    respond_to do |format|
      if @site_node.update_attributes(params[:site_node].permit!)
        format.html { redirect_to(cpanel_site_nodes_path, :notice => 'Site node 更新成功。') }
        format.json
      else
        format.html { render :action => "edit" }
        format.json
      end
    end
  end

  def destroy
    @site_node = SiteNode.find(params[:id])
    @site_node.destroy

    respond_to do |format|
      format.html { redirect_to(cpanel_site_nodes_path,:notice => "删除成功。") }
      format.json
    end
  end
end
