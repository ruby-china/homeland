module Admin
  class ApplicationsController < Admin::ApplicationController
    before_action :set_application, only: [:show, :edit, :update, :destroy]

    def index
      @applications = Doorkeeper::Application.order(id: :desc).paginate(page: params[:page], per_page: 20)
    end

    def show
    end

    def new
      @application = Doorkeeper::Application.new
    end

    def edit
    end

    def create
      @application = Doorkeeper::Application.new(params[:application].permit!)

      if @application.save
        redirect_to(admin_applications_path, notice: 'Application 创建成功。')
      else
        render action: 'new'
      end
    end

    def update
      if @application.update_attributes(params[:application].permit!)
        redirect_to(admin_applications_path, notice: 'Application 更新成功。')
      else
        render action: 'edit'
      end
    end

    def destroy
      @application.destroy
      redirect_to(admin_applications_path, notice: '删除成功。')
    end

    private

    def set_application
      @application = Doorkeeper::Application.find(params[:id])
    end
  end
end
