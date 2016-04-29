module Admin
  class ExceptionLogsController < Admin::ApplicationController
    def index
      @exception_logs = ExceptionLog.order(id: :desc).paginate(page: params[:page], per_page: 20)
    end

    def show
      @exception_log = ExceptionLog.find(params[:id])
    end

    def clean
      ExceptionLog.delete_all
      redirect_to admin_exception_logs_path, notice: '清空成功。'
    end

    def destroy
      @exception_log = ExceptionLog.find(params[:id])
      @exception_log.destroy
    end
  end
end
