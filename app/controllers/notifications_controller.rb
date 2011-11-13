# coding: utf-8
class NotificationsController < ApplicationController
  before_filter :require_user
  respond_to :html, :js, :only => [:destroy, :mark_all_as_read]

  def index
    @notifications = current_user.notifications.recent.paginate :page => params[:page], :per_page => 20
    current_user.read_notifications(@notifications)
    set_seo_meta("提醒")
  end

  def destroy
    @notification = current_user.notifications.find params[:id]
    @notification.destroy
    respond_with do |format|
      format.html { redirect_referrer_or_default notifications_path }
      format.js { render :layout => false }
    end
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(:read => true)
    respond_with do |format|
      format.html { redirect_referrer_or_default notifications_path }
      format.js { render :layout => false }
    end
  end
end
