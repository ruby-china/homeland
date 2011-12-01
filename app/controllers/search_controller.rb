# coding: utf-8
class SearchController < ApplicationController

  before_filter :validate_search_key

  def index

    if @q.present?
      @topics = Topic.search(@q).paginate(:page => params[:page], :per_page => 20)
    end

    render :action => :topics
  end

  def topics
    
    if @q.present?
      @topics = Topic.search(@q).paginate(:page => params[:page], :per_page => 20)
    end
    
    set_seo_meta("#{t("common.search")}: #{@q}")
    drop_breadcrumb("#{t("common.search")}: #{@q}")
  end

  def wiki
    if @q.present?
      @pages = Page.search(@q).paginate(:page => params[:page], :per_page => 20)
    end
    
    set_seo_meta("#{t("common.search")}: #{@q}")
    drop_breadcrumb("#{t("common.search")}: #{@q}")
  end

  protected

    def validate_search_key
      @q = params[:q].gsub(/\\|\'|-|\/|\.|\?/, "") if params[:q].present?
    end
end
