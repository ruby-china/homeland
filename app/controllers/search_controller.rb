class SearchController < ApplicationController
  def index
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
    @result = Elasticsearch::Model.search(search_params, [Topic, User, Page]).paginate(page: params[:page], per_page: 30)
  end
end
