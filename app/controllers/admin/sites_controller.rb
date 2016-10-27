module Admin
  class SitesController < Admin::ApplicationController
    require_module_enabled! :site
    before_action :set_site, only: [:show, :edit, :update, :destroy, :undestroy]

    def index
      @sites = Site.unscoped.recent.includes(:user, :site_node)
      if params[:q]
        @sites = @sites.where('name LIKE ?', "%#{params[:q]}%")
      end
      @sites = @sites.paginate(page: params[:page], per_page: 20)
    end

    def show
    end

    def new
      @site = Site.new
    end

    def edit
    end

    def create
      @site = Site.new(params[:site].permit!)

      if @site.save
        redirect_to(admin_sites_path, notice: 'Site 创建成功。')
      else
        render action: 'new'
      end
    end

    def update
      if @site.update_attributes(params[:site].permit!)
        redirect_to(admin_sites_path, notice: 'Site 更新成功。')
      else
        render action: 'edit'
      end
    end

    def destroy
      @site.destroy
      redirect_to(admin_sites_path, notice: "#{@site.name} 删除成功。")
    end

    def undestroy
      @site.update_attribute(:deleted_at, nil)
      redirect_to(admin_sites_path, notice: "#{@site.name} 已恢复。")
    end

    private

    def set_site
      @site = Site.unscoped.find(params[:id])
    end
  end
end
