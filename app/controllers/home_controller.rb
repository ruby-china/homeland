# coding: utf-8
class HomeController < ApplicationController
  def index
    @excellent_topics = Topic.excellent.recent.fields_for_list.includes(:user).limit(20).to_a
    drop_breadcrumb("首页", root_path)
    
    fresh_when(:etag => [@excellent_topics,SiteConfig.index_html])
  end

  def api
    drop_breadcrumb("API", root_path)
  end
  
  def twitter
    drop_breadcrumb("Twitter", root_path)
  end
end
