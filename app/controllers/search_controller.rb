# coding: utf-8
class SearchController < ApplicationController
  def index
    result = Redis::Search.query("Topic", params[:q], :limit => 500)
    ids = result.collect { |r| r["id"] }
    @topics = Topic.find(ids).paginate(:page => params[:page], :per_page => 20)

    set_seo_meta("#{t("common.search")}: #{params[:q]}")
    drop_breadcrumb("#{t("common.search")}: #{params[:q]}")
  end
end
