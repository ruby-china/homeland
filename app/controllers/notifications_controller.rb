# coding: utf-8
class NotificationsController < ApplicationController
  before_filter :require_user

  def index
    @notifications = current_user.notifications.paginate :page => params[:page], :per_page => 20
    set_seo_meta("提醒")
  end
end
