module Cpanel
  class ApplicationsController < ApplicationController
    def index
      @applications = Doorkeeper::Application.desc('_id').paginate(page: params[:page], per_page: 20)

      respond_to do |format|
        format.html # index.html.erb
        format.json
      end
    end

    def show
      @application = Doorkeeper::Application.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json
      end
    end

    def new
      @application = Doorkeeper::Application.new

      respond_to do |format|
        format.html # new.html.erb
        format.json
      end
    end

    def edit
      @application = Doorkeeper::Application.find(params[:id])
    end

    def create
      @application = Doorkeeper::Application.new(params[:application].permit!)

      respond_to do |format|
        if @application.save
          format.html { redirect_to(cpanel_applications_path, notice: 'Application 创建成功。') }
          format.json
        else
          format.html { render action: 'new' }
          format.json
        end
      end
    end

    def update
      @application = Doorkeeper::Application.find(params[:id])

      respond_to do |format|
        if @application.update_attributes(params[:application].permit!)
          format.html { redirect_to(cpanel_applications_path, notice: 'Application 更新成功。') }
          format.json
        else
          format.html { render action: 'edit' }
          format.json
        end
      end
    end

    def destroy
      @application = Doorkeeper::Application.find(params[:id])
      @application.destroy

      respond_to do |format|
        format.html { redirect_to(cpanel_applications_path, notice: '删除成功。') }
        format.json
      end
    end
  end
end
