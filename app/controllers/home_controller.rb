# coding: utf-8
class HomeController < ApplicationController
  def index
    @excellent_topics = Topic.excellent.recent.fields_for_list.includes(:user).limit(20)
    drop_breadcrumb("首页", root_path)
  end

  def api
    drop_breadcrumb("API", root_path)
  end
end
