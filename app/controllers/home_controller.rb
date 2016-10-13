class HomeController < ApplicationController
  def index
    @excellent_topics = Topic.excellent.recent.fields_for_list.limit(20).to_a
    fresh_when([@excellent_topics, Setting.index_html])
  end

  def api
    redirect_to "/api-doc/"
  end

  def error_404
    render_404
  end

  def markdown
  end
end
