module Admin
  class ExceptionLogsController < ApplicationController
    def index
      @exception_logs = ExceptionLog.order(id: :desc).paginate(page: params[:page], per_page: 20)

      respond_to do |format|
        format.html # index.html.erb
        format.json
      end
    end

    def show
      @exception_log = ExceptionLog.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json
      end
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
