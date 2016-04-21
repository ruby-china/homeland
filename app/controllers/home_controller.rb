class HomeController < ApplicationController
  def index
    @excellent_topics = Topic.excellent.recent.fields_for_list.limit(20).to_a

    fresh_when(etag: [@excellent_topics, Setting.index_html])
  end

  def api
    @routes = []
  end

  def twitter
    set_seo_meta t('menu.tweets')
  end

  def error_404
    render_404
  end

  def markdown
    set_seo_meta('Markdown Guide')
  end
end
