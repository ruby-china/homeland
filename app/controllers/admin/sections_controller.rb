module Admin
  class SectionsController < Admin::ApplicationController
    before_action :set_section, only: [:show, :edit, :update, :destroy]

    def index
      @sections = Section.all
    end

    def show
    end

    def new
      @section = Section.new
    end

    def edit
    end

    def create
      @section = Section.new(params[:section].permit!)

      if @section.save
        redirect_to(admin_sections_path, notice: "Section was successfully created.")
      else
        render action: "new"
      end
    end

    def update
      if @section.update(params[:section].permit!)
        redirect_to(admin_sections_path, notice: "Section was successfully updated.")
      else
        render action: "edit"
      end
    end

    def destroy
      @section.destroy

      redirect_to(admin_sections_url)
    end

    private

    def set_section
      @section = Section.find(params[:id])
    end
  end
end
