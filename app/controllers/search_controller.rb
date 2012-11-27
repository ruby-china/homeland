# coding: utf-8
class SearchController < ApplicationController
  def index
    redirect_to "https://www.google.com.hk/#hl=zh-CN&q=site:ruby-china.org+#{params[:q]}"
  end
end
