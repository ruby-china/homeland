module Admin
  class ApplicationsController < Admin::ApplicationController
    before_action :set_application, only: %i[show edit update destroy]

    def index
      @applications = Doorkeeper::Application.all
      if params[:q].present?
        qstr = "%#{params[:q].downcase}%"
        @applications = @applications.where("name LIKE ?", qstr)
      end
      if params[:level].present?
        @applications = @applications.where(level: params[:level])
      end
      if params[:uid].present?
        @applications = @applications.where(uid: params[:uid])
      end
      @applications = @applications.order(id: :desc).page(params[:page])
    end

    def show
    end

    def new
      @application = Doorkeeper::Application.new
    end

    def edit
    end

    def create
      @application = Doorkeeper::Application.new(params[:doorkeeper_application].permit!)

      if @application.save
        redirect_to(admin_applications_path, notice: "Application 创建成功。")
      else
        render action: "new"
      end
    end

    def update
      if @application.update(params[:doorkeeper_application].permit!)
        redirect_to(admin_applications_path, notice: "Application 更新成功。")
      else
        render action: "edit"
      end
    end

    def destroy
      @application.destroy
      redirect_to(admin_applications_path, notice: "删除成功。")
    end

    private

    def set_application
      @application = Doorkeeper::Application.find(params[:id])
    end
  end
end
