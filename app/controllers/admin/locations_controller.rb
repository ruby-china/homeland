module Admin
  class LocationsController < Admin::ApplicationController
    before_action :set_location, only: [:show, :edit, :update, :destroy]

    def index
      @locations = Location.hot.paginate(page: params[:page], per_page: 20)
    end

    def edit
    end

    def update
      if @location.update_attributes(params[:location].permit!)
        redirect_to(admin_locations_path, notice: 'Location 更新成功。')
      else
        render action: 'edit'
      end
    end

    private

    def set_location
      @location = Location.find(params[:id])
    end
  end
end
