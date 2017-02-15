module Admin
  class SiteNodesController < Admin::ApplicationController
    require_module_enabled! :site
    before_action :set_site_node, only: [:show, :edit, :update, :destroy]

    def index
      @site_nodes = SiteNode.order(id: :desc).paginate(page: params[:page], per_page: 20)
    end

    def show
    end

    def new
      @site_node = SiteNode.new
    end

    def edit
    end

    def create
      @site_node = SiteNode.new(site_node_params)

      if @site_node.save
        redirect_to(admin_site_nodes_path, notice: 'Site node 创建成功。')
      else
        render action: 'new'
      end
    end

    def update
      if @site_node.update(site_node_params)
        redirect_to(admin_site_nodes_path, notice: 'Site node 更新成功。')
      else
        render action: 'edit'
      end
    end

    def destroy
      @site_node.destroy
      redirect_to(admin_site_nodes_path, notice: '删除成功。')
    end

    private

    def site_node_params
      params[:site_node].permit!
    end

    def set_site_node
      @site_node = SiteNode.find(params[:id])
    end
  end
end
