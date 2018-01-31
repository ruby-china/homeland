module Admin
  class LocationsController < Admin::ApplicationController
    before_action :set_location, only: %i[show edit update destroy]

    def index
      @locations = Location.hot.page(params[:page])
    end

    def edit
    end

    def update
      if @location.update(params[:location].permit!)
        redirect_to(admin_locations_path, notice: "Location 更新成功。")
      else
        render action: "edit"
      end
    end

    private

    def set_location
      @location = Location.find(params[:id])
    end
  end
end
