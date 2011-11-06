# coding: utf-8
class NotificationsController < ApplicationController
  before_filter :require_user

  def index
    @notifications = current_user.notifications.order_by([[:created_at, :desc]]).paginate :page => params[:page], :per_page => 20
    current_user.read_notifications(@notifications)
    set_seo_meta("提醒")
  end
end
