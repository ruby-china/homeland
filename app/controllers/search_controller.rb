class SearchController < ApplicationController
  before_action :authenticate_user!, only: [:users]

  def index
    search_modules = [Topic, User]
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
      q = params[:q].downcase + '%'
      @result = User.where('login ilike ? or name ilike ?', q, q).order('replies_count desc').limit(8)
    else
      @result = current_user.following.limit(8)
    end
    render json: @result.collect { |u| { login: u.login, name: u.name, avatar_url: u.large_avatar_url } }
  end
end
