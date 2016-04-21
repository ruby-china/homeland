module Admin
  class SectionsController < ApplicationController
    def index
      @sections = Section.all
    end

    def show
      @section = Section.find(params[:id])
    end

    def new
      @section = Section.new
    end

    def edit
      @section = Section.find(params[:id])
    end

    def create
      @section = Section.new(params[:section].permit!)

      if @section.save
        redirect_to(admin_sections_path, notice: 'Section was successfully created.')
      else
        render action: 'new'
      end
    end

    def update
      @section = Section.find(params[:id])

      if @section.update_attributes(params[:section].permit!)
        redirect_to(admin_sections_path, notice: 'Section was successfully updated.')
      else
        render action: 'edit'
      end
    end

    def destroy
      @section = Section.find(params[:id])
      @section.destroy

      redirect_to(admin_sections_url)
    end
  end
end
