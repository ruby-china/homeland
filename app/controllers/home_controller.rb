# coding: utf-8
class HomeController < ApplicationController
  caches_action :index, :expires_in => 1.hours

  def index
    drop_breadcrumb("首页", root_path)
  end
end
