# coding: utf-8
class SearchController < ApplicationController
  def index
    keywords = params[:q] || ""
    keywords.gsub!("#", "%23")
    redirect_to "https://www.google.com.hk/#hl=zh-CN&q=site:ruby-china.org+#{keywords}"
  end
end
