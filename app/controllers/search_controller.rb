# coding: utf-8
class SearchController < ApplicationController
  def index
    
    @q = params[:q].gsub(/\\|\'|-|\/|\.|\?/, "") if params[:q].present?

    if @q.present?
      @topics = Topic.search(@q).paginate(:page => params[:page], :per_page => 20)
      @pages = Page.search(@q).paginate(:page => params[:page], :per_page => 20)
    end

    set_seo_meta("#{t("common.search")}: #{@q}")
    drop_breadcrumb("#{t("common.search")}: #{@q}")

    render :stream => true
  end
end
