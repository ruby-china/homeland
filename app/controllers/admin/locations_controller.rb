module Admin
  class LocationsController < Admin::ApplicationController
    before_action :set_location, only: [:show, :edit, :update, :destroy]

    def index
      @locations = Location.hot.paginate(page: params[:page], per_page: 20)
    end

    def show
    end

    def new
      @location = Location.new
    end

    def edit
    end

    def create
      @location = Location.new(params[:location].permit!)

      if @location.save
        redirect_to(admin_locations_path, notice: 'Location 创建成功。')
      else
        render action: 'new'
      end
    end

    def update
      if @location.update_attributes(params[:location].permit!)
        redirect_to(admin_locations_path, notice: 'Location 更新成功。')
      else
        render action: 'edit'
      end
    end

    def destroy
      @location.destroy
      redirect_to(admin_locations_path, notice: '删除成功。')
    end

    private

    def set_location
      @location = Location.find(params[:id])
    end
  end
end
