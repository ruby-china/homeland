# coding: utf-8
class HomeController < ApplicationController
  caches_action :index, :expires_in => 1.hours, :layout => false

  def index
    drop_breadcrumb("首页", root_path)
    FayeClient.send("/notifications_count/35", :count => 20)
  end

  def api
    drop_breadcrumb("API", root_path)
  end
end
