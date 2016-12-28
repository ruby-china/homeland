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
      @result = Elasticsearch::Model.search({
        query: {
          multi_match: {
            type: :phrase_prefix,
            query: params[:q],
            fields: [:login, :name]
          }
        }
      }, [User]).records
    else
      @result = current_user.following.limit(10)
    end
    render json: @result.collect { |u| { login: u.login, name: u.name, avatar_url: u.large_avatar_url } }
  end
end
