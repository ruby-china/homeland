class HomeController < ApplicationController
  def index
    @excellent_topics = Topic.excellent.recent.fields_for_list.limit(20).to_a

    fresh_when(etag: [@excellent_topics, SiteConfig.index_html])
  end

  def api
    @routes = []
    Api::Dispatch.routes.each do |route|
      next if route.route_method.blank?
      path = route.route_path
      path.sub!('(.:format)', '.json')
      path.sub!('/:version', '')

      r = {
        id: path.dasherize,
        method: route.route_method,
        name: path,
        params: route.route_params,
        desc: route.route_description
      }
      @routes << r
    end
    @routes.sort_by! { |a| a[:name] }
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
