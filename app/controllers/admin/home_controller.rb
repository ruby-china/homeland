# frozen_string_literal: true

module Admin
  class HomeController < Admin::ApplicationController
    def index
      @recent_topics = Topic.recent.limit(5)
    end
  end
end
