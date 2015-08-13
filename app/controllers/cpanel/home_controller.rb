# coding: utf-8
module Cpanel
  class HomeController < ApplicationController
    def index
      @recent_topics = Topic.recent.limit(5)
    end
  end
end
