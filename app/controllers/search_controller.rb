# coding: utf-8
class SearchController < ApplicationController
  def index
    search_text = params[:q]
    @search = Topic.solr_search do
      keywords search_text, :highlight => true
      paginate :page => params[:page], :per_page => 10
    end

    set_seo_meta("#{t("common.search")}: #{params[:q]}")
    drop_breadcrumb("#{t("common.search")}: #{params[:q]}")
  end

  def wiki
    search_text = params[:q]
    @search = Sunspot.search(Page) do
      keywords search_text, :highlight => true
      paginate :page => params[:page], :per_page => 10
    end

    set_seo_meta("WIKI#{t("common.search")}: #{params[:q]}")
    drop_breadcrumb("WIKI#{t("common.search")}: #{params[:q]}")
  end
end
