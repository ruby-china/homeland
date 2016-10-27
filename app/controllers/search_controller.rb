class SearchController < ApplicationController
  before_action :authenticate_user!, only: [:users]

  def index
    search_modules = [Topic]
    search_modules << Page if Setting.has_module?(:wiki)
    search_params = {
      query: {
        simple_query_string: {
          query: params[:q],
          default_operator: 'AND',
          minimum_should_match: '70%',
          fields: %w(title body name login)
        }
      },
      highlight: {
        pre_tags: ['[h]'],
        post_tags: ['[/h]'],
        fields: { title: {}, body: {}, name: {}, login: {} }
      }
    }
    @result = Elasticsearch::Model.search(search_params, search_modules).paginate(page: params[:page], per_page: 30)
  end

  def users
    @result = []
    if params[:q].present?
      users = User.prefix_match(params[:q], limit: 100)
      users.sort_by! { |u| current_user.following_ids.index(u['id']) || 9999999999 }
      @result = users.collect { |u| { login: u['title'], name: u['name'], avatar_url: u['large_avatar_url'] } }
    else
      users = current_user.following.limit(10)
      @result = users.collect { |u| { login: u.login, name: u.name, avatar_url: u.large_avatar_url } }
    end
    render json: @result
  end
end
