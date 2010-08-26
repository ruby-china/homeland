# coding: utf-8  
class Cpanel::HomeController < Cpanel::ApplicationController
  def index
    @recent_topics = Topic.recents.all(:limit => 5)
  end
end
