# coding: UTF-8
class Cpanel::ExceptionLogsController < Cpanel::ApplicationController

  def index
    @exception_logs = ExceptionLog.desc('_id').paginate(page: params[:page], per_page: 20)

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
    ExceptionLog.where(:id.in => params[:ids].split(",")).delete_all
    
    redirect_to cpanel_exception_logs_path, notice: "清空成功。"
  end

  def destroy
    @exception_log = ExceptionLog.find(params[:id])
    @exception_log.destroy
  end
end
